import json
import os
import smtplib
from email.message import EmailMessage
from datetime import datetime
from typing import Tuple, Any

MAILTRAP_HOST = os.environ.get("MAILTRAP_HOST", "smtp.mailtrap.io")
MAILTRAP_PORT = int(os.environ.get("MAILTRAP_PORT", "25"))
MAILTRAP_USER = os.environ["MAILTRAP_USER"]
MAILTRAP_PASS = os.environ["MAILTRAP_PASS"]
FROM_EMAIL = os.environ.get("FROM_EMAIL", "no-reply@hackathon.com")
SUBJECT_PREFIX = os.environ.get("SUBJECT_PREFIX", "[Video Service] ")


def get_user_email(user_id):
    # TODO integrar com user_service
    return user_id


def send_mail(to_email: str, subject: str, text: str):
    msg = EmailMessage()
    msg["From"] = FROM_EMAIL
    msg["To"] = to_email
    msg["Subject"] = subject
    msg.set_content(text)

    with smtplib.SMTP(MAILTRAP_HOST, MAILTRAP_PORT) as server:
        server.starttls()
        server.login(MAILTRAP_USER, MAILTRAP_PASS)
        server.send_message(msg)

def _render_email(payload: dict) -> tuple[str, str, str]:
    video_id = payload.get("video_id", "N/A")
    user_id = payload.get("user_id", "N/A")
    status = payload.get("status", "UPDATED")
    occurred_at = payload.get("occurred_at", datetime.now())

    email = get_user_email(user_id)

    subject = f"Seu vídeo {video_id} foi atualizado!"
    text = f"Olá!\n\nSeu vídeo {video_id} foi atualizado para: {status} as {occurred_at}."

    return email, subject, text

def lambda_handler(event, context):
    for record in event.get("Records", []):
        try:
            body_raw = record["body"]
            payload = json.loads(body_raw) if isinstance(body_raw, str) else body_raw

            to_email, subject, text = _render_email(payload)
            send_mail(to_email, subject, text)
            print(f"Email enviado para {to_email} | video_id={payload.get('video_id')}")
        except Exception as e:
            print(f"Falha ao processar mensagem: {e}")
            raise
