#!/usr/bin/env bash
set -euo pipefail

MODEL="${1:-qwen2.5:7b}"

docker compose up -d

echo "Aguardando Ollama subir..."
for _ in $(seq 1 60); do
  if curl -fsS http://localhost:11434/api/tags >/dev/null; then
    break
  fi
  sleep 2
done

curl -fsS http://localhost:11434/api/tags >/dev/null

echo "Baixando modelo ${MODEL}..."
docker compose exec -T ollama ollama pull "${MODEL}"

echo "Ollama pronto em http://localhost:11434"
