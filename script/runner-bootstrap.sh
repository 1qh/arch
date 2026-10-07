#!/bin/sh
# Idempotent bootstrap for the self-hosted GitHub Actions runners on this mac.
# Writes the per-job disk-cleanup hook, wires it into every runner instance,
# prunes superseded runner-version dirs + regenerable cruft, and activates the
# wiring by restarting the runner services. Safe to re-run; no-op when green.
set -e
ROOT="${RUNNER_ROOT:-$HOME/.actions-runners}"
HOOK="$ROOT/job-cleanup.sh"
HOOK_VAR="ACTIONS_RUNNER_HOOK_JOB_COMPLETED=$HOOK"

[ -d "$ROOT" ] || { echo "no runner root at $ROOT" >&2; exit 1; }

# 1. (re)write the cleanup hook — git clean -ffdx wipes node_modules/.next/.turbo/dist
#    after every job; next job re-checks-out clean and reinstalls from the bun cache.
cat > "$HOOK" <<'HOOK_EOF'
#!/bin/sh
# GitHub Actions job-completed hook: reclaim runner disk after every job.
# Runs once per job with GITHUB_WORKSPACE set to the repo checkout.
if [ -n "$GITHUB_WORKSPACE" ] && [ -d "$GITHUB_WORKSPACE/.git" ]; then
  git -C "$GITHUB_WORKSPACE" clean -ffdx >/dev/null 2>&1
fi
exit 0
HOOK_EOF
chmod +x "$HOOK"

# 2. wire the hook into every runner instance .env (idempotent)
changed=0
for env in "$ROOT"/*/[0-9]*/.env; do
  [ -f "$env" ] || continue
  grep -q 'ACTIONS_RUNNER_HOOK_JOB_COMPLETED' "$env" || { printf '%s\n' "$HOOK_VAR" >> "$env"; changed=1; }
done

# 3. prune superseded runner-version dirs (keep the symlink-active version) + cruft
for inst in "$ROOT"/*/[0-9]*/; do
  [ -L "$inst/bin" ] || continue
  active=$(readlink "$inst/bin" | sed 's#.*/bin\.##')
  [ -n "$active" ] || continue
  for d in "$inst"bin.* "$inst"externals.*; do
    [ -e "$d" ] || continue
    ver=$(basename "$d" | sed -E 's/^(bin|externals)\.//')
    [ "$ver" = "$active" ] || rm -rf "$d"
  done
  rm -rf "$inst"_work/_update
  rm -f "$inst"*.tar.gz
  find "$inst"_diag -name '*.log' -mtime +2 -delete 2>/dev/null || true
done

# 4. activate new wiring (runners read .env at service start); only when changed
if [ "$changed" = 1 ]; then
  uid=$(id -u)
  launchctl list 2>/dev/null | awk '/actions\.runner/{print $3}' | while IFS= read -r label; do
    launchctl kickstart -k "gui/$uid/$label" 2>/dev/null || true
  done
fi

echo ok
