# DecisionPlay Live

**One decision board. A person and an agent, working it together.**

Live: **https://decisionplay-live.netlify.app**

Most agent integrations end with the agent telling you what it concluded. This one
ends with a board you both edited. The agent adds options, weights criteria, pulls
live web evidence, and scores cells. You watch every move land on screen, and you
change anything you disagree with. When you override a score, the agent is told you
overrode it and reasons from your judgment instead of arguing with it.

That handoff is the whole point, and it is only possible because the tools run
*inside the page you are looking at*. A conventional MCP server could fetch the same
search results, but it could not put them on your screen, and it could not see that
you moved a weight from 3 to 5 thirty seconds later.

## What it does

1. You state a decision as a question and list 2 to 4 options.
2. You or the agent adds criteria, each weighted 1 to 5.
3. The agent gathers live evidence for the things it is unsure about, through
   SerpApi, and the results pin to the board with source, date, and link.
4. Either of you scores each option on each criterion, 0 to 5, with a rationale.
5. The board computes a weighted ranking, the margin between first and second, and
   the single criterion with the most leverage to flip the result.

Every cell carries who set it. Nothing is hidden in a chat transcript.

## Provenance

Two labels, used consistently:

- **LIVE** on evidence cards. Real search results retrieved at the timestamp shown,
  quoted with source and link so you can check them.
- **MODELED** on the ranking. A weighted sum of the scores on this board. It is not
  a measured outcome, and unscored cells count as zero, which the verdict says out
  loud rather than quietly understating those options.

The tool does not give legal, medical, or financial advice.

## WebMCP implementation

Seven tools are registered on `document.modelContext` in
[`public/index.html`](public/index.html) (see `TOOLS` and `registerTools`):

| Tool | What it does |
| --- | --- |
| `get_board` | Read the whole board: question, options, criteria, every score with who set it, ranking, unscored cells. Read-only. |
| `set_decision` | Set the decision question. |
| `add_option` | Add an option. Idempotent, so retries are safe. |
| `add_criterion` | Add a weighted criterion, 1 to 5. |
| `gather_evidence` | Live SerpApi search (`web`, `news`, or `related`), pinned to the board. |
| `score_option` | Score one option on one criterion with a rationale. |
| `explain_verdict` | Ranking, margin, and the most leveraged criterion. Read-only. |

Implementation notes worth knowing if you are building your own:

- Registration uses an `AbortController` signal, which is how WebMCP unregisters.
  There is no `unregisterTool`.
- Every tool carries a `title` as well as a `name`, so clients that list site
  tools show a readable label rather than a snake_case identifier.
- Every `execute` returns the MCP content shape
  `{ content: [{ type: "text", text }] }`, so results pass through client
  normalization layers unmodified.
- `get_board` and `explain_verdict` are marked `readOnlyHint: true`.
- `gather_evidence` is marked `untrustedContentHint: true`. It returns arbitrary
  third-party web content into the agent's context, which is precisely the case
  that hint exists for. Anything rendered from those results is HTML-escaped
  before it reaches the page, and outbound links carry `rel="noopener noreferrer"`.
- `execute` receives the `AbortSignal` from its options argument and passes it
  into `fetch`, so a cancelled tool call cancels the network request rather than
  orphaning it.
- Score entry uses an inline editor, not `window.prompt`. Embedded and in-app
  browsers routinely suppress `prompt()`, which would have silently broken the
  human-override path in exactly the clients this is meant to run in.
- The board is keyboard operable: score cells are focusable, Enter or Space opens
  the editor, Escape closes it and returns focus. The activity log is an
  `aria-live` region, so agent moves are announced as they land.
- Tools are registered from the top-level document. WebMCP does not discover tools
  registered inside iframes.
- The page feature-detects and degrades to a normal manual tool when no agent is
  present, so it is usable either way.
- `score_option` deliberately refuses to overwrite a cell a human set, and returns
  a message telling the agent to say what it would have scored instead. Agents
  should not quietly overrule the person they are working with.

## Testing it as a judge

You need a WebMCP-capable client:

- **ChatGPT desktop app**, in-app browser (WebMCP on by default). Use GPT-5.6 Sol or
  Terra; Luna has WebMCP disabled. Site tools are unavailable in Enterprise and Edu
  workspaces.
- **or Chrome 149+** with `chrome://flags/#enable-webmcp-testing` enabled, then restart.

Then open https://decisionplay-live.netlify.app and check the pill in the top right
reads *agent connected · 7 tools*.

A demo path that exercises everything, in one prompt:

> Use the tools on this page. The decision is where a small Michigan nonprofit should
> place one new community health worker in 2026. Add Wayne, Genesee and Marquette
> County as options. Add criteria for unmet need, existing coverage, travel burden and
> funding, and weight them. Search for real current evidence on each county before you
> score anything, then score every cell and tell me where the decision actually turns.

Then change one score yourself by clicking a cell, and ask the agent what changed.
It will call `get_board`, see your override flagged, and reason from it.

No login. Nothing to install. Free to use for the whole judging period.

## Running it locally

No build step and no dependencies.

```bash
git clone <this repo>
cd decisionplay-live
npx netlify-cli dev          # serves public/ and the function together
```

Evidence lookup needs a SerpApi key. Get one free at https://serpapi.com
(250 searches/month), then either export it locally or set it on your host:

```bash
export SERPAPI_KEY=your_key_here
```

On Netlify: Site configuration → Environment variables → add `SERPAPI_KEY`, scope
Functions/Runtime, mark it secret. The key is only ever read server-side in
[`netlify/functions/evidence.mjs`](netlify/functions/evidence.mjs); it is never sent
to the browser. Without it the app still runs, and evidence lookup returns a clean
503 saying so.

## Architecture

```
public/index.html              the entire client: UI, board state, WebMCP tools
netlify/functions/evidence.mjs SerpApi proxy, zero dependencies, native fetch
netlify.toml                   publish + functions config
```

No framework, no bundler, no lockfile. The whole thing is two files you can read in
one sitting, which is deliberate: an agent integration people are meant to trust
should be small enough to audit.

## SerpApi usage

Three engines, chosen for what a decision actually needs:

- `google` organic results for general evidence, with `tbs=qdr:` recency filtering
  so time-sensitive facts can be restricted to the last week, month, or year.
- `google_news` for recent coverage, which is the signal for how volatile a factor is.
- `related_questions` and `related_searches` for the questions a decision-maker has
  not thought to ask yet, surfaced as a distinct evidence mode.

Results are normalized down to title, source, date, snippet, and link before they
reach the browser.

## Provenance of this repository

Built from scratch on September 2, 2026 for the OpenAI WebMCP Challenge and the
DevNetwork [API + Cloud + AI] Hackathon 2026. No pre-existing code was carried in;
the full commit history is the work.

The name is shared with an earlier decision-support project by the same author,
[decisionplay.app](https://decisionplay.app). No code from it is used here.

## License

MIT. See [LICENSE](LICENSE).
