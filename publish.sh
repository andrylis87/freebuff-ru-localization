#!/usr/bin/env bash
#
# publish.sh — assemble and publish the Freebuff Russian localization repo.
#
#   ./publish.sh
#
# Optional environment variables:
#   GH_TOKEN / GITHUB_TOKEN  Personal Access Token (repo scope). If unset you
#                            are prompted for it, hidden from the terminal.
#   ARTIFACTS_DIR            Where the artifacts live (default: this script's dir)
#   DEST_DIR                 Where the repo folder is created (default: next to the script)
#   GH_OWNER / GH_REPO       Override the GitHub target
#
# The token is passed to git through a temporary GIT_ASKPASS helper. It is
# never written to disk, never stored in .git/config and never put on the
# command line.

set -euo pipefail

OWNER="${GH_OWNER:-andrylis87}"
REPO="${GH_REPO:-freebuff-ru-localization}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${ARTIFACTS_DIR:-$SCRIPT_DIR}"

if [ "$(basename "$SCRIPT_DIR")" = "$REPO" ] && [ -z "${DEST_DIR:-}" ]; then
  DEST="$SCRIPT_DIR"
else
  DEST="${DEST_DIR:-$SCRIPT_DIR}/$REPO"
fi

FILES=(
  README.md
  README_RU.md
  GLOSSARY_RU.md
  LICENSE
  NOTICE
  freebuff-ru-localization.patch
  freebuff-ru-localization.zip
  publish.sh
)

echo "==> Checking artifacts in $SRC"
missing=0
for f in "${FILES[@]}"; do
  if [ ! -f "$SRC/$f" ]; then
    echo "    MISSING: $f" >&2
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  echo "Put publish.sh next to the artifacts (or set ARTIFACTS_DIR) and rerun." >&2
  exit 1
fi

echo "==> Creating $DEST"
mkdir -p "$DEST"
if [ "$(cd "$SRC" && pwd)" != "$(cd "$DEST" && pwd)" ]; then
  for f in "${FILES[@]}"; do
    cp -f "$SRC/$f" "$DEST/$f"
  done
fi
cd "$DEST"

echo "==> git init"
[ -d .git ] || git init -q
git branch -M main

# Local identity only; never touches your global git config.
[ -n "$(git config user.name)" ]  || git config user.name  "$OWNER"
[ -n "$(git config user.email)" ] || git config user.email "${OWNER}@users.noreply.github.com"

echo "==> Commit"
git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "feat: initial Russian localization release"
else
  echo "    nothing new to commit"
fi

echo "==> Remote"
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$OWNER/$REPO.git"

# --- token -----------------------------------------------------------------
TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
if [ -z "$TOKEN" ]; then
  if [ -t 0 ]; then
    printf 'GitHub PAT for %s/%s (input hidden): ' "$OWNER" "$REPO" >&2
    IFS= read -rs TOKEN </dev/tty
    echo >&2
  else
    echo "Set GH_TOKEN (Personal Access Token with 'repo' scope) and rerun." >&2
    exit 1
  fi
fi
if [ -z "$TOKEN" ]; then
  echo "No token supplied, aborting." >&2
  exit 1
fi

ASKPASS="$(mktemp)"
trap 'rm -f "$ASKPASS"' EXIT
cat > "$ASKPASS" <<'EOF'
#!/bin/sh
case "$1" in
  [Uu]sername*) printf '%s\n' "$PUBLISH_USER" ;;
  *)            printf '%s\n' "$PUBLISH_TOKEN" ;;
esac
EOF
chmod 700 "$ASKPASS"

echo "==> Pushing to https://github.com/$OWNER/$REPO"
export PUBLISH_USER="$OWNER"
export PUBLISH_TOKEN="$TOKEN"
export GIT_ASKPASS="$ASKPASS"
export SSH_ASKPASS="$ASKPASS"
export GIT_TERMINAL_PROMPT=0

# credential.helper= (empty) clears any system helper so git asks GIT_ASKPASS.
git -c credential.helper= push -u origin main

echo
echo "Done: https://github.com/$OWNER/$REPO"
