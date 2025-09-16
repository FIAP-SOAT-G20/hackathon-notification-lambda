# Hackathon Notification Lambda

Lambda responsável por enviar **emails de notificação** quando vídeos são processados.
As mensagens chegam via **SQS Notification Queue** e são entregues aos usuários via **Mailtrap (SMTP)**.

---

## 📂 Estrutura do Repositório

```
hackathon-notification-lambda/
   infra/
      main.tf
      variables.tf
      outputs.tf
      lambda/
         lambda_function.py
   .github/
      workflows/
         deploy.yml
   README.md
```


---

## ⚙️ Fluxo da Lambda

1. Mensagens são publicadas na **notification queue** (SQS).
2. A Lambda é disparada automaticamente.
3. O código processa a mensagem, monta o email e envia via **Mailtrap SMTP**.

---

## 📌 Tecnologias

- **AWS Lambda** (execução do código Python)
- **AWS SQS** (fila já existente, apenas consumida)
- **Terraform** (infraestrutura como código)
- **GitHub Actions** (CI/CD para deploy automático)
- **Mailtrap** (entrega de email em ambiente de teste)

---

## 🚀 Deploy Automatizado (GitHub Actions)

O deploy é feito automaticamente sempre que houver commit na branch `main`.
O workflow está em `.github/workflows/deploy.yml`.

### 🔑 Secrets necessários no GitHub

Adicione os seguintes secrets no repositório:

| Secret                          | Descrição                                               |
|---------------------------------|---------------------------------------------------------|
| `AWS_ACCESS_KEY_ID`             | Chave de acesso da AWS                                  |
| `AWS_SECRET_ACCESS_KEY`         | Secret da chave de acesso                               |
| `AWS_REGION`                    | Região AWS (ex.: `us-east-1`)                           |
| `TF_BACKEND_BUCKET`             | Nome do bucket S3 para state do Terraform               |
| `TF_BACKEND_KEY`                | Caminho do arquivo de state no bucket                   |
| `TF_BACKEND_REGION`             | Região do bucket S3                                     |
| `TF_BACKEND_LOCK_TABLE`         | Tabela DynamoDB para lock do state                      |
| `TF_VAR_notification_queue_arn` | ARN da SQS de notificação (fornecida pela outra equipe) |
| `TF_VAR_mailtrap_user`          | Usuário SMTP do Mailtrap                                |
| `TF_VAR_mailtrap_pass`          | Senha SMTP do Mailtrap                                  |
| `TF_VAR_from_email`             | Email remetente (ex.: `no-reply@example.com`)           |
| `TF_VAR_subject_prefix`         | Prefixo do assunto dos emails (ex.: `[Video Service] `) |

---

## 👨‍💻 Desenvolvimento Local

Se quiser rodar o código localmente para testar:

1. Criar e ativar um venv:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt  # (se houver)
    ```

2. Criar arquivo .env com variáveis:

    ```
    MAILTRAP_USER=xxxx
    MAILTRAP_PASS=xxxx
    FROM_EMAIL=no-reply@example.com
    SUBJECT_PREFIX=[Video Service]
    MAILTRAP_HOST=smtp.mailtrap.io
    MAILTRAP_PORT=587
    ```

3. Rodar o handler com evento de exemplo:

    ```bash
    python -m infra.lambda.lambda_function
    ```

## Evento de Teste (SQS)

Exemplo de payload que a Lambda vai receber:

````json
{
  "Records": [
    {
      "body": "{\"email\":\"user@example.com\",\"video_id\":\"12345\",\"status\":\"PROCESSED\",\"download_url\":\"https://example.com/video/12345\"}"
    }
  ]
}

````

## Infraestrutura (Terraform)

Na pasta infra/:

````bash
cd infra
terraform init
terraform plan
terraform apply
````


