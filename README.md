# Hackathon Notification Lambda

Lambda responsible for sending **notification emails** when videos are processed.  
Messages arrive via **SQS Notification Queue** and are delivered to users through **Mailtrap (SMTP)**.

---

## 📂 Repository Structure

```
hackathon-notification-lambda/
   terraform/
      main.tf
      variables.tf
      outputs.tf
   .github/
      workflows/
         deploy.yml
   main.py
   README.md
   requirements.txt
```

---

## ⚙️ Lambda Flow

1. Messages are published in the **notification queue** (SQS).  
2. The Lambda is triggered automatically.  
3. The code processes the message, builds the email, and sends it via **Mailtrap SMTP**.

---

## 📌 Technologies

- **AWS Lambda** (Python code execution)  
- **AWS SQS** (existing queue, only consumed)  
- **Terraform** (infrastructure as code)  
- **GitHub Actions** (CI/CD for automatic deployment)  
- **Mailtrap** (email delivery in a testing environment)  

---

## 🚀 Automated Deployment (GitHub Actions)

The deployment is done automatically whenever there is a commit to the `main` branch.  
The workflow is in `.github/workflows/deploy.yml`.

### 🔑 Required GitHub Secrets

Add the following secrets to the repository:

| Secret                          | Description                                                    |
|---------------------------------|----------------------------------------------------------------|
| `AWS_ACCESS_KEY_ID`             | AWS access key                                                 |
| `AWS_SECRET_ACCESS_KEY`         | AWS access key secret                                          |
| `AWS_REGION`                    | AWS region (e.g.: `us-east-1`)                                 |
| `TF_BACKEND_BUCKET`             | S3 bucket name for Terraform state                             |
| `TF_BACKEND_KEY`                | Path of the state file in the bucket                           |
| `TF_BACKEND_REGION`             | S3 bucket region                                               |
| `TF_BACKEND_LOCK_TABLE`         | DynamoDB table for state lock                                  |
| `TF_VAR_notification_queue_arn` | Notification SQS ARN (provided by the other team)              |
| `TF_VAR_mailtrap_user`          | Mailtrap SMTP user                                             |
| `TF_VAR_mailtrap_pass`          | Mailtrap SMTP password                                         |
| `TF_VAR_from_email`             | Sender email (e.g.: `no-reply@example.com`)                    |
| `TF_VAR_subject_prefix`         | Email subject prefix (e.g.: `[Video Service] `)                |

---

## 👨‍💻 Local Development

If you want to run the code locally for testing:

1. Create and activate a venv:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt  # (if any)
   ```

2. Create a .env file with variables:

   ```
   MAILTRAP_USER=xxxx
   MAILTRAP_PASS=xxxx
   FROM_EMAIL=no-reply@example.com
   SUBJECT_PREFIX=[Video Service]
   MAILTRAP_HOST=smtp.mailtrap.io
   MAILTRAP_PORT=587
   ```

3. Run the handler with a sample event:

   ```bash
   python main.py
   ```

## Test Event (SQS)

Example of payload the Lambda will receive:

```json
{
  "Records": [
    {
      "body": "{\"user_id\":42,\"video_id\":\"12345\",\"status\":\"FINISHED\",\"occurred_at\":\"20250918\"}"
    }
  ]
}
```

## Infrastructure (Terraform)

Inside the infra/ folder:

```bash
cd infra
terraform init
terraform plan
terraform apply
```
