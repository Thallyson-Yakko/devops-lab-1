# Desafio DevOps Junior — Infraestrutura Local com MiniStack

## Cenário

Uma equipe de desenvolvimento criou uma API simples e precisa da sua ajuda para montar toda a infraestrutura de forma local usando [MiniStack](https://github.com/Nahuel990/ministack), simulando um ambiente AWS real.

> **MiniStack** é uma alternativa ao LocalStack, 100% compatível com as mesmas configurações e endpoints.

A API (já fornecida em `app/`) possui dois endpoints:

- `POST /upload/<filename>` — faz upload de um arquivo para o S3 e envia uma mensagem para uma fila SQS
- `GET /files` — lista os arquivos armazenados no bucket S3

## O que você deve entregar

### 1. Docker (40%)

- Criar um `Dockerfile` para a aplicação dentro de `app/`:
  - Imagem base leve (ex: `python:3.12-slim`)
  - Usuário não-root
  - Apenas dependências necessárias

- Criar um `docker-compose.yml` na raiz do projeto que suba:
  - A aplicação (porta 8080)
  - O MiniStack (porta 4566) — imagem: `ghcr.io/nahuel990/ministack`
  - Rede configurada para que a aplicação consiga acessar o MiniStack

- As variáveis de ambiente da aplicação devem ser configuradas no compose:
  - `AWS_ENDPOINT_URL` — endpoint do MiniStack
  - `S3_BUCKET` — nome do bucket
  - `SQS_QUEUE_URL` — URL da fila SQS
  - `AWS_ACCESS_KEY_ID=test`
  - `AWS_SECRET_ACCESS_KEY=test`
  - `AWS_DEFAULT_REGION=us-east-1`

### 2. Terraform + MiniStack (40%)

- Dentro do diretório `terraform/`, criar os recursos apontando para o MiniStack:
  - **Bucket S3** para armazenamento dos arquivos
  - **Fila SQS** para mensageria
- O provider AWS deve estar configurado para o endpoint do MiniStack
- Organização mínima esperada: `main.tf`, `variables.tf`, `outputs.tf`
- Os outputs devem expor o nome do bucket e a URL da fila

### 3. Documentação (20%)

- Atualizar este README com:
  - Instruções de como subir tudo do zero (passo a passo)
  - Diagrama simples do fluxo de rede (pode ser ASCII/texto)
  - Decisões técnicas que você tomou e por quê

## Pré-requisitos

- Docker e Docker Compose
- Terraform
- curl (para testar)

## Como validar

Após subir o ambiente, os seguintes comandos devem funcionar:

```bash
# Upload de arquivo
curl -X POST http://localhost:8080/upload/teste.txt
# Esperado: {"status": "ok", "file": "teste.txt"}

# Listar arquivos
curl http://localhost:8080/files
# Esperado: {"files": ["teste.txt"]}
```

## Critérios de Avaliação

| Critério | O que será observado |
|---|---|
| Dockerfile | Imagem otimizada, segura, funcional |
| Docker Compose | Serviços sobem, rede funciona, variáveis corretas |
| Terraform | Recursos criados no MiniStack, código organizado |
| Documentação | Clareza, diagrama, instruções que funcionam |

## Prazo

2 a 3 dias.

## Bônus (diferencial)

- Health check no docker-compose
- Terraform com backend local organizado
- Script ou Makefile que suba tudo com um único comando
- Teste automatizado end-to-end (upload + listagem)

---

> **Abaixo deste ponto, adicione sua documentação.**

---
# Documentação — DevOps Lab 1

## Visão Geral

Laboratório prático de DevOps que configura uma infraestrutura local simulando serviços AWS utilizando **MiniStack**, com uma aplicação Flask containerizada, provisionamento via **Terraform** e orquestração via **Docker Compose**.

---

## Tecnologias Utilizadas

| Tecnologia | Versão | Finalidade |
|---|---|---|
| Python | 3.12-slim | Runtime da aplicação Flask |
| Flask | 3.1.1 | Framework web/API |
| boto3 | 1.38.0 | SDK AWS para Python |
| MiniStack | latest | Emulação local de serviços AWS |
| Docker | — | Containerização da aplicação |
| Docker Compose | — | Orquestração dos containers |
| Terraform | 1.14.8 | Infraestrutura como código |
| AWS Provider (Terraform) | 6.40.0 | Provedor Terraform para AWS/MiniStack |

---

## Estrutura do Projeto

```
devops-lab-1-master/
├── .gitignore                     # Arquivos ignorados pelo Git
├── Dockerfile                     # Imagem Docker da aplicação Flask
├── docker-compose.yaml            # Orquestração dos containers
├── app/
│   ├── app.py                     # API Flask principal
│   └── requirements.txt           # Dependências Python
└── terraform/
    ├── main.tf                    # Provider + recursos S3 e SQS
    ├── variables.tf               # Variáveis de entrada
    ├── output.tf                  # Outputs do Terraform
    └── .terraform.lock.hcl        # Lock de versões dos providers
```

---

## Componentes

### Dockerfile

Containeriza a aplicação Flask com boas práticas de segurança e otimização.

**Destaques:**
- Imagem base leve: `python:3.12-slim`
- Execução com usuário não-root (`app_user`) — prevenção de escalação de privilégios
- Variáveis de ambiente para otimização do Python:
  - `PYTHONDONTWRITEBYTECODE=1` — não gera arquivos `.pyc`
  - `PYTHONUNBUFFERED=1` — saída de log em tempo real
- Porta exposta: `8080`

**Build da imagem:**
```bash
docker build -t app_sqs:latest .
```

---

### Docker Compose

Orquestra dois serviços em rede isolada:

| Serviço | Imagem | Porta | Função |
|---|---|---|---|
| `app` | `app_sqs:latest` | `8080:8080` | API Flask |
| `ministack` | `ministackorg/ministack:latest` | `4566:4566` | Emulador AWS local |

**Variáveis de ambiente do serviço `app`:**

```yaml
AWS_ENDPOINT_URL: http://ministack:4566
AWS_DEFAULT_REGION: us-east-1
AWS_ACCESS_KEY_ID: test
AWS_SECRET_ACCESS_KEY: test
S3_BUCKET: test-ministack
SQS_QUEUE_URL: http://ministack:4566/000000000000/test-sqs
```

**Subir o ambiente:**
```bash
docker compose up -d
```

**Derrubar o ambiente:**
```bash
docker compose down
```

---

### Aplicação Flask (`app/app.py`)

API REST que interage com S3 e SQS via boto3, apontando para o MiniStack.

#### Endpoints

**`POST /upload/<filename>`**

Faz upload de um arquivo para o bucket S3 e envia uma notificação para a fila SQS.

```bash
curl -X POST http://localhost:8080/upload/meuarquivo.txt
```

Resposta:
```json
{"status": "ok", "file": "meuarquivo.txt"}
```

---

**`GET /files`**

Lista todos os arquivos presentes no bucket S3.

```bash
curl http://localhost:8080/files
```

Resposta:
```json
{"files": ["meuarquivo.txt", "outro.txt"]}
```

---

### Terraform

Provisiona os recursos de infraestrutura no MiniStack via IaC.

#### Recursos criados

| Recurso | Tipo | Nome |
|---|---|---|
| Bucket S3 | `aws_s3_bucket` | `test-ministack` |
| Fila SQS | `aws_sqs_queue` | `test-sqs` |

#### Provider configurado para MiniStack

```hcl
provider "aws" {
  region                      = var.region
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    s3  = "http://localhost:4566"
    sqs = "http://localhost:4566"
  }
}
```

#### Variáveis (`variables.tf`)

| Variável | Padrão | Descrição |
|---|---|---|
| `region` | `us-east-1` | Região AWS |
| `access_key` | `test` | Chave de acesso (dummy para local) |
| `secret_key` | `test` | Chave secreta (dummy para local) |
| `bucket` | `test-ministack` | Nome do bucket S3 |
| `aws_sqs_queue` | `test-sqs` | Nome da fila SQS |

#### Comandos Terraform

```bash
cd terraform/

# Inicializar providers
terraform init

# Visualizar plano de execução
terraform plan

# Aplicar infraestrutura
terraform apply

# Destruir infraestrutura
terraform destroy
```

---

## Como Executar o Projeto Completo

### Pré-requisitos

- Docker e Docker Compose instalados
- Terraform instalado (`>= 1.14`)

### Passo a Passo

**1. Subir o MiniStack e a aplicação:**
```bash
docker compose up -d
```

**2. Aguardar o MiniStack inicializar (alguns segundos) e provisionar a infraestrutura:**
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

**3. Testar os endpoints:**
```bash
# Fazer upload de um arquivo
curl -X POST http://localhost:8080/upload/teste.txt

# Listar arquivos no bucket
curl http://localhost:8080/files
```

**4. Encerrar o ambiente:**
```bash
docker compose down
cd terraform && terraform destroy -auto-approve
```

---

## .gitignore — O que é ignorado e por quê

| Arquivo/Diretório | Motivo |
|---|---|
| `terraform/terraform.tfstate` | Contém o estado atual da infraestrutura — pode ter dados sensíveis e é específico de cada ambiente |
| `terraform/terraform.tfstate.backup` | Backup automático do estado anterior |
| `terraform/.terraform/` | Diretório com binários dos providers (~774MB) — regenerado via `terraform init` |
| `__pycache__/`, `*.pyc` | Bytecode compilado Python — gerado automaticamente |
| `venv/`, `env/` | Ambientes virtuais Python — específicos da máquina local |
| `.env` | Variáveis de ambiente sensíveis (senhas, tokens) |
| `.DS_Store` | Arquivo de metadados do macOS — não relevante para o projeto |
| `*.log` | Arquivos de log gerados em runtime |

> **Nota:** O arquivo `.terraform.lock.hcl` **não** está no `.gitignore pois é recomendado versioná-lo para garantir que todos usem as mesmas versões dos providers.

---

## Arquitetura

```
┌─────────────────────────────────────┐
│           Docker Compose            │
│                                     │
│  ┌──────────────┐  ┌─────────────┐  │
│  │  Flask App   │  │  MiniStack  │  │
│  │  :8080       │──▶  :4566      │  │
│  │              │  │             │  │
│  │  POST /upload│  │  S3 Bucket  │  │
│  │  GET /files  │  │  SQS Queue  │  │
│  └──────────────┘  └─────────────┘  │
│         ▲                ▲          │
└─────────┼────────────────┼──────────┘
          │                │
    curl/HTTP         Terraform
    (usuário)         (provisiona recursos)
```

---

## Observações

- As credenciais AWS (`test`/`test`) são fictícias e usadas apenas para autenticação local com o MiniStack.
- O MiniStack emula os serviços S3 e SQS na porta `4566`, replicando o comportamento da AWS real.
- O projeto foi desenvolvido como laboratório didático de práticas DevOps: containerização, IaC e integração de serviços.
