/**
 * Live evidence lookup for DecisionPlay Live.
 *
 * Proxies SerpApi so the key never reaches the browser. Zero dependencies:
 * native fetch only, so this deploys without an install step.
 *
 * Three modes, all backed by SerpApi:
 *   mode=web     google organic results, optionally recency-filtered
 *   mode=news    google_news, used for the volatility signal
 *   mode=related google "related questions" / people-also-ask, used to surface
 *                the questions a decision-maker has not thought to ask yet
 */

const SERPAPI = "https://serpapi.com/search.json";

const RECENCY = {
  any: null,
  year: "qdr:y",
  month: "qdr:m",
  week: "qdr:w",
};

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json",
      "cache-control": "no-store",
    },
  });
}

function domainOf(url) {
  try {
    return new URL(url).hostname.replace(/^www\./, "");
  } catch {
    return "";
  }
}

/** Trims a SerpApi organic result down to what the board actually renders. */
function normalizeOrganic(r) {
  return {
    title: r.title || "",
    link: r.link || "",
    source: r.source || domainOf(r.link || ""),
    snippet: r.snippet || "",
    date: r.date || null,
  };
}

function normalizeNews(r) {
  return {
    title: r.title || "",
    link: r.link || "",
    source: (r.source && (r.source.name || r.source)) || domainOf(r.link || ""),
    snippet: r.snippet || "",
    date: r.date || null,
  };
}

export default async function handler(request) {
  if (request.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const key = process.env.SERPAPI_KEY;
  if (!key) {
    return json(
      {
        error: "missing_key",
        message:
          "SERPAPI_KEY is not set on this deploy. Evidence lookup is unavailable.",
      },
      503,
    );
  }

  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const query = typeof body.query === "string" ? body.query.trim() : "";
  if (!query || query.length > 300) {
    return json({ error: "invalid_query" }, 400);
  }

  const mode = ["web", "news", "related"].includes(body.mode) ? body.mode : "web";
  const recency = RECENCY[body.recency] ?? null;

  const params = new URLSearchParams({
    api_key: key,
    q: query,
    hl: "en",
    gl: "us",
    num: "10",
  });

  if (mode === "news") {
    params.set("engine", "google_news");
  } else {
    params.set("engine", "google");
    if (recency) params.set("tbs", recency);
  }

  const started = Date.now();
  let payload;
  try {
    const res = await fetch(`${SERPAPI}?${params.toString()}`, {
      signal: AbortSignal.timeout(20000),
    });
    payload = await res.json();
    if (!res.ok || payload.error) {
      return json(
        { error: "serpapi_error", message: payload.error || `HTTP ${res.status}` },
        502,
      );
    }
  } catch (err) {
    return json({ error: "serpapi_unreachable", message: String(err) }, 502);
  }

  const latencyMs = Date.now() - started;

  if (mode === "news") {
    const items = (payload.news_results || []).slice(0, 6).map(normalizeNews);
    return json({ mode, query, latencyMs, items });
  }

  if (mode === "related") {
    const questions = (payload.related_questions || [])
      .slice(0, 6)
      .map((q) => ({
        question: q.question || "",
        snippet: q.snippet || "",
        link: q.link || "",
        source: q.source ? q.source.name || q.source : domainOf(q.link || ""),
      }))
      .filter((q) => q.question);
    const searches = (payload.related_searches || [])
      .slice(0, 8)
      .map((s) => s.query)
      .filter(Boolean);
    return json({ mode, query, latencyMs, questions, searches });
  }

  const items = (payload.organic_results || []).slice(0, 6).map(normalizeOrganic);
  const answerBox = payload.answer_box
    ? {
        title: payload.answer_box.title || "",
        answer:
          payload.answer_box.answer ||
          payload.answer_box.snippet ||
          payload.answer_box.result ||
          "",
        link: payload.answer_box.link || "",
        source: payload.answer_box.displayed_link
          ? domainOf(payload.answer_box.link || "")
          : "",
      }
    : null;

  return json({ mode, query, recency: body.recency || "any", latencyMs, items, answerBox });
}

export const config = { path: "/api/evidence" };
