#!/usr/bin/env bash
# ship.sh — finds the project, sets the SerpApi key on Netlify, redeploys,
# creates the public repo, pushes, and verifies all of it.
#
#   bash ship.sh
#
# It will ASK for the SerpApi key, so you never have to paste it onto a command
# line. Get one free (250 searches/month, no card):
#   https://serpapi.com/users/sign_up  ->  https://serpapi.com/manage-api-key
#
# The key is used only for `netlify env:set`. It is never written into the repo
# and never committed.

set -uo pipefail

SITE_ID="eafeda46-fd22-48f4-8a53-9ff71f5c3878"
SITE="decisionplay-live"
REPO="saebchicago/decisionplay-live"
URL="https://decisionplay-live.netlify.app"

bold() { printf "\n\033[1m%s\033[0m\n" "$*"; }
ok()   { printf "  \033[32mok\033[0m    %s\n" "$*"; }
bad()  { printf "  \033[31mFAIL\033[0m  %s\n" "$*"; }
warn() { printf "  \033[33mnote\033[0m  %s\n" "$*"; }
FAILED=0

# ------------------------------------------------------- 1. find the project
bold "1/5  Finding the project"

WORK=""
# Already sitting in it?
if [ -f "./public/index.html" ] && [ -f "./netlify.toml" ]; then
  WORK="$(pwd)"
  ok "using the folder you're already in"
fi

# An already-extracted folder?
if [ -z "$WORK" ]; then
  for d in "$HOME/Downloads/decisionplay-live" "$HOME/decisionplay-live" "$HOME/decisionplay/decisionplay-live"; do
    if [ -f "$d/public/index.html" ]; then WORK="$d"; ok "found extracted folder at $d"; break; fi
  done
fi

# A zip, under any name Safari/Chrome may have given it.
if [ -z "$WORK" ]; then
  ZIP="$(find "$HOME/Downloads" "$HOME" -maxdepth 2 -iname '*decisionplay*live*.zip' 2>/dev/null \
        | head -1)"
  if [ -n "$ZIP" ]; then
    DEST="$(cd "$(dirname "$ZIP")" && pwd)"
    rm -rf "$DEST/decisionplay-live"
    if unzip -q -o "$ZIP" -d "$DEST" 2>/dev/null; then
      WORK="$DEST/decisionplay-live"
      ok "unzipped $(basename "$ZIP")"
    fi
  fi
fi

if [ -z "$WORK" ] || [ ! -f "$WORK/public/index.html" ]; then
  bad "Can't find the project."
  echo
  echo "  Here's what is actually in your Downloads folder:"
  ls -1t "$HOME/Downloads" 2>/dev/null | head -15 | sed 's/^/    /'
  echo
  echo "  If you see the zip above under a different name, run:"
  echo "    unzip -o ~/Downloads/'THE NAME YOU SEE.zip' -d ~/Downloads"
  echo "    cd ~/Downloads/decisionplay-live && bash ship.sh"
  exit 1
fi

cd "$WORK" || exit 1
ok "working in $WORK"

# ------------------------------------------------------------- 2. the key
bold "2/5  SerpApi key"

KEY="${1:-}"
if [ -z "$KEY" ]; then
  echo "  Paste your SerpApi key and press Return."
  echo "  (It will not echo to the screen. That is normal — paste and hit Return.)"
  printf "  key: "
  read -r -s KEY
  echo
fi

if [ -z "$KEY" ]; then
  bad "No key entered."
  echo "  Get one at https://serpapi.com/manage-api-key then re-run: bash ship.sh"
  echo "  Or set it by hand in the Netlify UI and re-run to do the rest:"
  echo "    Netlify -> $SITE -> Site configuration -> Environment variables"
  exit 1
fi

if ! command -v netlify >/dev/null 2>&1; then
  warn "netlify CLI not found. Installing — takes a minute or two, it is not hung."
  npm i -g netlify-cli 2>&1 | tail -1
fi

if command -v netlify >/dev/null 2>&1; then
  if netlify env:set SERPAPI_KEY "$KEY" --site "$SITE_ID" --context production --secret >/dev/null 2>&1 \
     || netlify env:set SERPAPI_KEY "$KEY" --site "$SITE_ID" >/dev/null 2>&1; then
    ok "SERPAPI_KEY set on $SITE"
  else
    bad "could not set it (try: netlify login, then re-run)"
    echo "     Or set it by hand: Netlify -> $SITE -> Site configuration ->"
    echo "     Environment variables -> SERPAPI_KEY, scopes Functions + Runtime, secret."
    FAILED=1
  fi
else
  bad "netlify CLI unavailable — set SERPAPI_KEY in the Netlify UI, then re-run."
  FAILED=1
fi
unset KEY

# ------------------------------------------------------------- 3. redeploy
bold "3/5  Redeploying so the function sees the key"
if command -v netlify >/dev/null 2>&1; then
  if netlify deploy --prod --dir=public --functions=netlify/functions \
       --site "$SITE_ID" --message "wire SERPAPI_KEY" >/dev/null 2>&1; then
    ok "redeployed"
  else
    warn "CLI deploy failed — trigger one in the Netlify UI (Deploys -> Trigger deploy)"
    FAILED=1
  fi
else
  warn "skipped"
fi

# ------------------------------------------------------------ 4. public repo
bold "4/5  Public repo"
[ -d .git ] || git init -b main >/dev/null 2>&1
git add -A >/dev/null 2>&1
if git diff --cached --quiet 2>/dev/null; then
  warn "nothing new to commit"
else
  git commit -q -F - <<'MSG'
feat: DecisionPlay Live, a shared decision board with WebMCP tools and SerpApi evidence

A decision board an agent and a person edit together. Seven tools registered on
document.modelContext let an agent add options, weight criteria, gather live web
evidence through SerpApi, and score cells, while the person watches and overrides.
score_option refuses to overwrite a human-set cell by design.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01NfkrXYcBSMWd4KQC6wky23
MSG
  ok "committed"
fi

if command -v gh >/dev/null 2>&1; then
  if gh repo view "$REPO" >/dev/null 2>&1; then
    git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$REPO.git"
    git push -u origin main >/dev/null 2>&1 && ok "pushed to existing repo" || { bad "push failed"; FAILED=1; }
  else
    gh repo create "$REPO" --public --source=. --push >/dev/null 2>&1 \
      && ok "created https://github.com/$REPO" || { bad "gh repo create failed (try: gh auth login)"; FAILED=1; }
  fi
else
  bad "gh CLI not found. Install with: brew install gh && gh auth login"
  echo "     Or create it at https://github.com/new — name decisionplay-live, PUBLIC,"
  echo "     do NOT add README/gitignore/license — then:"
  echo "       git remote add origin https://github.com/$REPO.git && git push -u origin main"
  FAILED=1
fi

# --------------------------------------------------------------- 5. verify
bold "5/5  Verifying"
sleep 4

CODE=$(curl -s -o /dev/null -w '%{http_code}' "$URL/")
[ "$CODE" = "200" ] && ok "site up — $URL" || { bad "site returned $CODE"; FAILED=1; }

EV=$(curl -s -X POST "$URL/api/evidence" -H 'content-type: application/json' \
  -d '{"query":"Genesee County Michigan community health worker","mode":"web","recency":"year"}')
if echo "$EV" | grep -q '"items"'; then
  N=$(echo "$EV" | grep -o '"title"' | wc -l | tr -d ' ')
  ok "SerpApi LIVE — $N real results came back"
elif echo "$EV" | grep -q 'missing_key'; then
  bad "function still can't see the key — trigger a fresh deploy in the Netlify UI"
  FAILED=1
else
  bad "unexpected response: $(echo "$EV" | head -c 160)"
  FAILED=1
fi

if command -v gh >/dev/null 2>&1 && gh repo view "$REPO" >/dev/null 2>&1; then
  VIS=$(gh repo view "$REPO" --json visibility -q .visibility 2>/dev/null)
  LIC=$(gh repo view "$REPO" --json licenseInfo -q '.licenseInfo.spdxId // "none"' 2>/dev/null)
  [ "$VIS" = "PUBLIC" ] && ok "repo is PUBLIC" || { bad "repo is $VIS — must be PUBLIC"; FAILED=1; }
  [ "$LIC" = "MIT" ] && ok "GitHub detects the MIT license" || { bad "license shows as: $LIC"; FAILED=1; }
fi

echo
if [ "$FAILED" -eq 0 ]; then
  bold "Done. Both blockers cleared."
  echo "  Live:   $URL"
  echo "  Repo:   https://github.com/$REPO"
  echo "  Record: $URL/?example=1"
  echo
  echo "  Left: the video, then paste the two submissions from SUBMISSIONS.md."
else
  bold "Some steps need you — see the FAIL lines above."
fi
