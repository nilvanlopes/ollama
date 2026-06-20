#!/usr/bin/env bash
set -euo pipefail

echo "Checking WSL GPU access..."
if nvidia-smi >/dev/null 2>&1; then
  echo "nvidia-smi: OK"
else
  echo "nvidia-smi: FAILED"
  nvidia-smi || true
fi

echo
echo "Checking Docker GPU hint..."
if docker compose config >/dev/null 2>&1; then
  echo "docker compose config: OK"
else
  echo "docker compose config: FAILED"
fi

echo
echo "Checking Ollama endpoint..."
if curl -fsS http://localhost:11434/api/tags >/dev/null 2>&1; then
  echo "http://localhost:11434/api/tags: OK"
else
  echo "http://localhost:11434/api/tags: FAILED"
fi
