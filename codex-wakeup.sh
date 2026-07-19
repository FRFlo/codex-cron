#!/usr/bin/env bash
set -euo pipefail

workdir="${CODEX_WORKDIR:-/app/runtime}"

{
  echo "=== START $(date --iso-8601=seconds) ==="
  cd "$workdir"
  if /usr/local/bin/codex exec \
    --model gpt-5.4-mini \
    -c 'model_reasoning_effort="low"' \
    --skip-git-repo-check \
    --ephemeral \
    "hi"; then
    echo "codex exec exit code: 0"
    echo "codex exec completed successfully"
  else
    exit_code=$?
    echo "codex exec exit code: ${exit_code}"
    echo "=== END $(date --iso-8601=seconds) ==="
    exit "$exit_code"
  fi
  echo "=== END $(date --iso-8601=seconds) ==="
}
