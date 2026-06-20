# Ollama Local

Projeto Docker para subir Ollama local no WSL com GPU e expor a API em `http://localhost:11434`.

## Pré-requisitos

- WSL2 com integração ativa no Docker Desktop ou Docker Engine acessível pelo WSL.
- Driver NVIDIA instalado no Windows com suporte a WSL 2 GPU Paravirtualization.
- `nvidia-smi` funcionando no WSL.
- Docker com suporte a `gpus: all`.

## Tutorial WSL + GPU

Use este fluxo quando o container falhar com `failed to discover GPU vendor from CDI` ou quando o Ollama não subir com GPU no WSL.

### 1. Verifique o WSL

No WSL, confirme que a GPU aparece:

```bash
nvidia-smi
```

Se esse comando falhar, o problema está no driver Windows, no WSL ou na integração do ambiente, não no projeto.

### 2. Atualize WSL e reinicie

No PowerShell do Windows:

```powershell
wsl --update
wsl --shutdown
```

Abra o WSL novamente e rode `nvidia-smi` de novo.

### 3. Confirme o Docker Desktop

Se você usa Docker Desktop:

- Use o backend WSL2.
- Confirme que o Docker Desktop está acessível pelo WSL.
- Reinicie o Docker Desktop depois de atualizar driver ou WSL.

### 4. Instale o NVIDIA Container Toolkit no WSL

No WSL, o runtime do Docker precisa do toolkit NVIDIA para expor a GPU aos containers.

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg2

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
  | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
  | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

### 5. Configure o runtime do Docker

Ainda no WSL:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
```

Depois reinicie o Docker:

```bash
sudo systemctl restart docker
```

Se você usa Docker Desktop, reinicie o Docker Desktop no Windows em vez do `systemctl`.

### 6. Valide a GPU dentro do Docker

Rode um container de teste:

```bash
docker run --rm -it --gpus=all nvcr.io/nvidia/k8s/cuda-sample:nbody nbody -gpu -benchmark
```

Se esse comando falhar com erro de GPU vendor ou CDI, o runtime NVIDIA ainda não está configurado corretamente no host.

### 7. Não instale driver Linux NVIDIA na distro

No WSL, não instale driver Linux NVIDIA dentro da distro. O driver deve vir do Windows e o acesso de container é feito pelo runtime NVIDIA no lado Linux.

### 8. Use o script de diagnóstico

O projeto inclui um verificador rápido:

```bash
./scripts/doctor.sh
```

Ele checa:

- `nvidia-smi` no WSL
- o `docker compose config`
- o endpoint `http://localhost:11434/api/tags`

## Subir

```bash
docker compose up -d
```

## Bootstrap

O script abaixo sobe o container, espera a API ficar disponível e baixa o modelo padrão:

```bash
./scripts/bootstrap.sh
```

Ou indique outro modelo:

```bash
./scripts/bootstrap.sh qwen2.5:14b
```

## Verificação

```bash
curl http://localhost:11434/api/tags
```

Se o WSL ainda não estiver liberando GPU, o diagnóstico vai acusar:

```bash
./scripts/doctor.sh
```

## Uso no app

O fluxo `job-application-automation` já está apontado para `http://localhost:11434/api`, então basta manter este projeto ativo.

## Troubleshooting

- Se o container falhar com `failed to discover GPU vendor from CDI`, o WSL ainda não tem acesso válido à GPU no lado Linux.
- Se `nvidia-smi` responder `GPU access blocked by the operating system`, o bloqueio está no ambiente WSL/Windows, não no Compose.
- Nesse caso, ajuste o driver NVIDIA para WSL e o suporte de GPU do Docker no host antes de rodar `docker compose up -d` de novo.
- Se `docker run --rm -it --gpus=all ...` falhar com erro de CDI, repita a etapa 5 e reinicie o Docker Desktop.
