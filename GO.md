# GO — four steps, ~20 minutes

Live now, current build: **https://decisionplay-live.netlify.app**

Deadlines: **DevNetwork Sep 3, 10:00 AM PDT** · **WebMCP Sep 3, 1:00 PM PDT**

---

## Step 1 — SerpApi key (5 min, do this first)

Evidence lookup is the whole DevNetwork entry, and it is dark until this is set.

1. Sign up free at https://serpapi.com/users/sign_up — 250 searches/month, no card needed for the free plan.
2. Copy the key from https://serpapi.com/manage-api-key
3. Netlify → **decisionplay-live** → Site configuration → Environment variables → Add:
   - Key: `SERPAPI_KEY`
   - Scopes: **Functions** and **Runtime**
   - Mark as **secret**
4. Redeploy so the function picks it up: Deploys → Trigger deploy → Deploy site.

Confirm it worked — this should return JSON with results, not an error:

```bash
curl -s -X POST https://decisionplay-live.netlify.app/api/evidence \
  -H 'content-type: application/json' \
  -d '{"query":"Genesee County Michigan health worker shortage","mode":"web","recency":"year"}' | head -c 400
```

I can't touch API keys, so this one is genuinely yours.

---

## Step 2 — public repo (1 paste, ~30 seconds)

WebMCP requires a public repo with a license GitHub can detect. This is a **new
standalone repo**, so nothing private of yours is exposed.

```bash
cd ~/Downloads && unzip -o decisionplay-live.zip && cd decisionplay-live

git init -b main
git add -A
git commit -m "feat: DecisionPlay Live, a shared decision board with WebMCP tools and SerpApi evidence

A decision board an agent and a person edit together. Seven tools registered on
document.modelContext let an agent add options, weight criteria, gather live web
evidence through SerpApi, and score cells, while the person watches and overrides.
score_option refuses to overwrite a human-set cell by design.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01NfkrXYcBSMWd4KQC6wky23"

gh repo create saebchicago/decisionplay-live --public --source=. --push
```

No `gh`? Create the repo at https://github.com/new (name `decisionplay-live`,
**Public**, no README/gitignore/license — the zip has them), then:

```bash
git remote add origin https://github.com/saebchicago/decisionplay-live.git
git push -u origin main
```

Then open the repo page and confirm the **About** sidebar on the right says
**MIT license**. If it doesn't, the WebMCP entry fails a hard gate.

---

## Step 3 — the video (10 min, WebMCP only)

Required: under 3 minutes, public or unlisted on YouTube, **with audio**. The rules
say judges may score on the video alone, so this carries more weight than it looks.

Setup that saves you time on camera:

- Open **https://decisionplay-live.netlify.app/?example=1** — the board loads
  pre-populated, so you don't burn 20 seconds clicking setup on tape.
- Open it in the ChatGPT desktop app's in-app browser (GPT-5.6 **Sol** or **Terra**;
  Luna has WebMCP off), or Chrome 149+ with `chrome://flags/#enable-webmcp-testing`.
- Confirm the pill reads **agent connected · 7 tools** before you hit record.

Beat sheet with timings is in `SUBMISSIONS.md` section 3. The one shot that matters
is at 1:45: change a score the agent set, then ask the agent what you changed. It
calls `get_board`, sees your override flagged, and reasons from your number. That is
the whole thesis of the submission in fifteen seconds.

Prompt to paste on camera:

```
Use the tools on this page. The decision is where a small Michigan nonprofit should
place one new community health worker in 2026. Add Wayne, Genesee and Marquette
County as options. Add criteria for unmet need, existing coverage, travel burden and
funding, and weight them. Search for real current evidence on each county before you
score anything, then score every cell and tell me where the decision actually turns.
```

---

## Step 4 — submit both

All copy is in `SUBMISSIONS.md`, ready to paste.

**DevNetwork** (do first, closes 10:00 AM) — https://api-cloud-ai-hackathon-2026.devpost.com
Needs: title, elevator pitch, description, project URL, and tick the
**SerpApi – Best AI Use Case** challenge. No video or repo required for this track.

**WebMCP** (closes 1:00 PM) — https://webmcp.devpost.com
Needs: live URL, the four-part description, public repo link, YouTube link, and the
testing instructions block.

Send me the repo and video URLs and I'll fill the forms through your browser if the
extension is behaving. Copy-pasting them yourself is about 10 minutes and won't fail.

---

## What's verified vs not

**Verified by me, headless:**
- All 7 tools register with correct shape, AbortSignal, and `readOnlyHint` on the two read tools
- Full agent workflow: set decision → add options → add criteria → score → read board → verdict
- Fuzzy name matching ("genesee" → Genesee County), duplicate adds report honestly, scores clamp to 0-5
- `score_option` refuses to overwrite a human-set cell and returns the right instruction
- `get_board` flags human overrides as `overrodeAgent: true`
- Verdict math correct, unscored cells disclosed rather than hidden
- Zero JS errors; app fully usable with no agent present
- Function routes at `/api/evidence` and fails clean without a key

**Not verified, and you should know it:**
- No real WebMCP client has run these tools. I tested against a mock of
  `document.modelContext` built from the W3C spec. Registration could still behave
  differently in ChatGPT's browser. **Check the pill says "agent connected · 7 tools"
  before you record.** That is the single go/no-go signal.
- No SerpApi call has ever succeeded, because there is no key yet. Step 1's curl is
  the proof. Run it.
- DevNetwork's rules are contradictory on pre-existing work (a stale 2024 handbook
  says none allowed; the 2026 rules are silent). Built-from-scratch-today makes this
  moot for us.
