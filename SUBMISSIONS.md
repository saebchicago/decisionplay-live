# Submission pack: DecisionPlay Live

Two hackathons, one build. Copy-paste ready. Deadlines are **hard** and both fall
on Wednesday September 3, 2026.

| | DevNetwork [API + Cloud + AI] | OpenAI WebMCP Challenge |
| --- | --- | --- |
| Deadline | **Sep 3, 10:00 AM PDT** | **Sep 3, 1:00 PM PDT** |
| Submit at | https://api-cloud-ai-hackathon-2026.devpost.com | https://webmcp.devpost.com |
| Track | SerpApi: Best AI Use Case ($3,000 / 2 winners) | Main ($3,500 / **10 winners**) |
| Video | not required for this track | **required**, <3 min, YouTube, with audio |
| Public repo | not required for this track | **required**, with detectable LICENSE |

Note the WebMCP deadline is **1:00 PM PT, not 5:00 PM**. The Devpost countdown and
the official rules both say 1:00 PM; only a community forum post says otherwise, and
the rules declare themselves controlling.

---

## 1. DevNetwork submission

**Project name**

```
DecisionPlay Live
```

**Elevator pitch** (one line)

```
A decision board where you and an AI agent work the same problem side by side, with every claim backed by a live web search you can click.
```

**Try it out**

```
https://decisionplay-live.netlify.app
```

**Sponsor challenge to select:** `SerpApi – Best AI Use Case`

**Here's the Whole Story**

```
THE PROBLEM

High-stakes decisions fail on stale facts. A team weighs three options against four
criteria, someone recalls a number from six months ago, and the ranking that comes
out is confidently wrong. The failure is rarely the reasoning. It is that the inputs
were remembered instead of checked.

Language models make this worse, not better. Ask one to compare options and it will
produce a fluent, well-organized answer built substantially out of recall, with no
way for you to see which parts are current and which are from training data.

WHAT WE BUILT

DecisionPlay Live is a shared decision board. You state a question, list 2 to 4
options, and add weighted criteria. Then every score on that board has to be earned:
before anything gets scored, live web evidence is pulled through SerpApi and pinned
to the board with its source, date, and a link you can click.

The ranking that comes out is a weighted sum, labeled MODELED, sitting directly
above the evidence it was built from. The board also computes the margin between
first and second place and identifies the single criterion with the most leverage to
flip the result, so you know where the decision actually turns and what would be
worth researching next.

HOW SERPAPI IS USED

Three engines, each chosen for something a decision genuinely needs:

- google organic results for general evidence, with tbs=qdr: recency filtering, so
  time-sensitive factors can be restricted to the last week, month, or year. A
  funding question and a demographics question do not need the same freshness.
- google_news for recent coverage. Volume and recency of news on a factor is itself
  the signal for how volatile that factor is, which is decision-relevant information
  separate from the content of any single article.
- related_questions and related_searches to surface the questions a decision-maker
  has not thought to ask yet. This is the mode that most often changes a board,
  because it adds criteria rather than scoring existing ones.

Results are normalized to title, source, date, snippet, and link before they reach
the browser. The API key lives only in a Netlify environment variable and is read
server-side in a zero-dependency function; it never reaches the client.

WHY LIVE SEARCH IS THE POINT, NOT A FEATURE

Strip SerpApi out and this becomes another confident ranking with nothing under it.
The evidence cards are what let a person disagree with the machine on specifics
rather than on vibes. Every card is quoted with its source so you can go read it and
decide the model misread it. That is the difference between a tool that asks for
trust and one that earns it.

THE AGENT LAYER

The board also registers seven tools on document.modelContext, the W3C WebMCP API,
so an AI agent in a WebMCP-capable browser can drive the board directly: add
options, weight criteria, run evidence searches, score cells with rationale, and
read back the current ranking. You watch every move land on screen.

When you override a score the agent set, the board records that you did, and the
agent is told on its next read. It reasons from your judgment rather than silently
re-overwriting it. The scoring tool refuses outright to overwrite a human-set cell,
and instead tells the agent to say what it would have scored and let you decide.

PROVENANCE

Two labels, used consistently. LIVE on evidence cards means a real search result
retrieved at the timestamp shown. MODELED on the ranking means a weighted sum of the
scores on this board, not a measured outcome. Unscored cells count as zero, and the
verdict says so out loud rather than quietly understating those options.

BUILT

September 2, 2026. Vanilla JavaScript, no framework and no build step, plus one
Netlify function. Two files you can read in a sitting, which is deliberate: a tool
that asks you to trust its evidence handling should be small enough to audit.

MIT licensed.
```

**Built with** (Devpost tags)

```
serpapi, webmcp, javascript, netlify, netlify-functions, html5, css3, vanilla-js, w3c, openai
```

---

## 2. WebMCP Challenge submission

**Project name**

```
DecisionPlay Live
```

**Elevator pitch**

```
A decision board an agent and a person edit together: the agent researches and scores, you override what you disagree with, and it reasons from your judgment instead of arguing with it.
```

**Live URL**

```
https://decisionplay-live.netlify.app
```

**Repository** — must be public with a detectable LICENSE (MIT file is in the repo root).

**Video** — YouTube, under 3 minutes, with audio. Script below.

**Description** — the rules require four specific points. Written against them in order:

```
WHY THIS USE CASE FITS WEBMCP

A decision is not a request. It is a workspace two parties keep changing.

Most agent integrations are request-shaped: you ask, the agent answers, the answer
arrives as text. That shape is a poor fit for deciding anything real, because the
interesting part is not the conclusion, it is the twenty small judgments underneath
it, each of which a person may want to disagree with.

WebMCP fits because it puts the agent's hands on the same surface the person is
looking at. The agent is not describing a decision board to me in prose. It is
editing the one on my screen, and I am editing it back, in the same session, with no
copy-paste between us. A conventional MCP server could fetch the same search
results. It could not put them on my screen, and it could not see that I moved a
weight from 3 to 5 thirty seconds later.

HOW IT MAKES THE EXPERIENCE BETTER

Three things change.

You can see the work. Options, criteria, weights, and scores appear on the board as
the agent creates them, each tagged with who set it. Nothing is buried in a
transcript you have to scroll back through.

You can interrupt at the level of a single judgment. If the agent scored one county
a 4 on unmet need and you know that is wrong, you click that cell and change it. You
do not have to re-litigate the whole analysis in prose to correct one number.

The evidence stays attached. Every live search the agent runs pins to the board with
source, date, and link, so a claim and the thing it came from stay in the same
place. You can disagree with a specific source rather than with the model's tone.

WHAT PEOPLE AND AGENTS CAN DO TOGETHER THAT WAS HARD BEFORE

Correct an agent mid-analysis and have it actually absorb the correction.

The board records who set every score. When you override a value the agent chose,
that override is flagged in the state the agent reads back through get_board. The
agent sees "this human overrode you here" and continues from your number.

The scoring tool goes further and refuses to overwrite a human-set cell at all. It
returns a message telling the agent to state what it would have scored and why, and
leave the decision to you. That is a deliberate stance: an agent working alongside
someone should not quietly overrule them, and WebMCP is the first place I have been
able to encode that as a property of the tool rather than a hope about the prompt.

The result is a genuine division of labor. The agent is better at breadth, running
twelve searches and drafting twelve rationales. The person is better at knowing that
the third one is wrong. Before this, those two things happened in different windows.

HOW WEBMCP IS IMPLEMENTED

Seven tools registered on document.modelContext in public/index.html:

  get_board         read question, options, criteria, every score with its author,
                    the ranking, and unscored cells. readOnlyHint: true.
  set_decision      set the decision question
  add_option        add an option, idempotent so retries are safe
  add_criterion     add a criterion weighted 1 to 5
  gather_evidence   live SerpApi search (web / news / related), pinned to the board
  score_option      score one cell with a rationale; refuses to overwrite a human
  explain_verdict   ranking, margin, most leveraged criterion. readOnlyHint: true.

Registration goes through an AbortController signal, which is how WebMCP
unregisters; there is no unregisterTool. Every tool carries a title as well as a
name, so a client listing site tools shows a readable label. Every execute returns
the MCP content shape { content: [{ type: "text", text }] } so results pass through
client normalization unmodified, and receives the AbortSignal from its options
argument, which gather_evidence passes into fetch so a cancelled call cancels the
request. Tools are registered from the top-level document, since WebMCP does not
discover tools inside iframes. The page feature-detects and degrades to a normal
manual tool when no agent is present, so it is a complete product either way.

gather_evidence is marked untrustedContentHint. It pulls arbitrary third-party web
content into the agent's context, which is the case that hint exists for. Everything
rendered from those results is HTML-escaped and outbound links carry noopener
noreferrer.

Score entry is an inline editor rather than window.prompt, because embedded and
in-app browsers routinely suppress prompt() and that would have silently broken the
override path in exactly the clients this runs in. The board is keyboard operable
and the activity log is an aria-live region.

Everything runs client-side except the SerpApi proxy, a zero-dependency Netlify
function that keeps the API key server-side.

No framework, no bundler, no lockfile. Two files.

PROVENANCE AND SCOPE

Built from scratch on September 2, 2026. No pre-existing code was carried in. It
shares a name with an earlier project by the same author, decisionplay.app, and
shares no code with it.

The ranking is labeled MODELED and the evidence LIVE, consistently, throughout the
interface. The tool does not give legal, medical, or financial advice.
```

**Testing instructions for judges** (paste into the testing-instructions field)

```
No login required. Free and open for the full judging period.

1. Open https://decisionplay-live.netlify.app in the ChatGPT desktop app's in-app
   browser (use GPT-5.6 Sol or Terra; Luna has WebMCP disabled), or in Chrome 149+
   with chrome://flags/#enable-webmcp-testing enabled and restarted.
2. Confirm the pill at the top right reads "agent connected - 7 tools".
3. Give the agent this prompt:

   Use the tools on this page. The decision is where a small Michigan nonprofit
   should place one new community health worker in 2026. Add Wayne, Genesee and
   Marquette County as options. Add criteria for unmet need, existing coverage,
   travel burden and funding, and weight them. Search for real current evidence on
   each county before you score anything, then score every cell and tell me where
   the decision actually turns.

4. Watch the board fill in. Evidence cards appear on the right with live sources.
5. Click any cell the agent scored and change the number. Then ask the agent
   "what did I just change, and does it move your recommendation?" It calls
   get_board, sees the override flagged as yours, and reasons from your value.

Step 5 is the one worth seeing.
```

---

## 3. Video script (WebMCP, under 3 minutes)

Record the screen with audio. Do not read this word for word; it is a beat sheet
with timings. The rules say judges may score on the video alone, so the tool calls
must be visible on screen.

**0:00–0:20 — the problem, over the empty board**

> High-stakes decisions usually fail on stale facts, not bad reasoning. And when you
> ask an AI to help, you get a fluent answer with no way to see which parts are
> current and which are remembered. This is DecisionPlay Live. It's a decision board
> that an agent and I work on together.

**0:20–0:35 — show the connection**

Point at the "agent connected · 7 tools" pill.

> Seven tools registered on document.modelContext. The agent isn't describing a board
> to me. It's editing the one I'm looking at.

**0:35–1:25 — the agent works, live**

Paste the demo prompt. Let it run. Narrate what lands as it lands.

> It's adding the options. Now criteria, with weights. And now it's searching, live,
> through SerpApi, before it scores anything. Those cards are real results with
> sources and dates, and I can click any of them. Now the scores come in, each one
> tagged AGENT, each with a rationale.

**1:25–1:45 — the verdict**

> Weighted ranking, labeled MODELED, because it's a weighted sum, not a measurement.
> And it tells me the margin, and which single criterion has enough leverage to flip
> the result. That's where the decision actually turns.

**1:45–2:30 — the override, the point of the whole thing**

Click a cell the agent scored. Change it. Show the tag flip to YOU.

> Here's the part I care about. The agent scored Genesee a 4 on unmet need. I work in
> this space. I think that's wrong. I click, I change it, and the board records that I
> overrode the agent.

Ask the agent: *what did I just change, and does it move your recommendation?*

> It calls get_board, sees my override flagged, and reasons from my number instead of
> re-arguing for its own. And if it tries to score that cell again, the tool refuses,
> and tells it to say what it would have scored and let me decide. That's encoded in
> the tool, not hoped for in a prompt.

**2:30–2:50 — close**

> An agent is better at breadth. Twelve searches, twelve rationales. I'm better at
> knowing the third one is wrong. Before WebMCP those happened in different windows.
> Two files, no framework, MIT licensed. DecisionPlay Live.

---

## 4. What only you can do

Four things, roughly 20 minutes total.

1. **SerpApi key.** Sign up free at https://serpapi.com (250 searches/month is
   plenty). Then in Netlify: `decisionplay-live` → Site configuration →
   Environment variables → add `SERPAPI_KEY`, scope **Functions** and **Runtime**,
   mark secret. I can't handle API keys directly. Until this is set, evidence
   lookup returns a clean 503 and the rest of the app works.

2. **Public GitHub repo.** WebMCP requires one, with a detectable license. The zip
   has everything including `LICENSE`. Create `saebchicago/decisionplay-live` as
   **public** — this is a new standalone repo, so your private repos stay private.
   Push, then confirm GitHub's About sidebar shows "MIT license".

3. **Record the video.** Script above. Under 3 minutes, audio required, upload to
   YouTube as public or unlisted.

4. **Submit both forms.** Copy blocks above. DevNetwork first, it closes at 10 AM.

I can fill the Devpost forms through your browser if you want; say the word and I'll
do it once the repo and video links exist.
