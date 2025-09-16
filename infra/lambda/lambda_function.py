import json
import os
import smtplib
from email.message import EmailMessage

MAILTRAP_HOST = os.environ.get("MAILTRAP_HOST", "smtp.mailtrap.io")
MAILTRAP_PORT = int(os.environ.get("MAILTRAP_PORT", "25"))
MAILTRAP_USER = os.environ["MAILTRAP_USER"]
MAILTRAP_PASS = os.environ["MAILTRAP_PASS"]
FROM_EMAIL = os.environ.get("FROM_EMAIL", "no-reply@example.com")
SUBJECT_PREFIX = os.environ.get("SUBJECT_PREFIX", "[Video Service] ")

def send_mail(to_email: str, subject: str, text: str, html: str | None = None):
    msg = EmailMessage()
    msg["From"] = FROM_EMAIL
    msg["To"] = to_email
    msg["Subject"] = subject
    msg.set_content(text)
    if html:
        msg.add_alternative(html, subtype="html")

    with smtplib.SMTP(MAILTRAP_HOST, MAILTRAP_PORT) as server:
        server.starttls()
        server.login(MAILTRAP_USER, MAILTRAP_PASS)
        server.send_message(msg)

def _render_email(payload: dict) -> tuple[str, str, str | None]:
    email = payload["email"]
    video_id = payload.get("video_id", "N/A")
    status = payload.get("status", "UPDATED")
    download_url = payload.get("download_url")

    subject = f"{SUBJECT_PREFIX}Seu vídeo {video_id} foi {status.lower()}"
    text = f"Olá!\n\nSeu vídeo {video_id} foi {status}."
    if download_url:
        text += f"\nBaixe aqui: {download_url}\n"

    html = None
    if download_url:
        html = (
            f"<p>Olá!</p>"
            f"<p>Seu vídeo <b>{video_id}</b> foi <b>{status}</b>.</p>"
            f'<p><a href="{download_url}">Clique aqui para baixar</a></p>'
        )
    return email, subject, text, html

def lambda_handler(event, context):
    for record in event.get("Records", []):
        try:
            body_raw = record["body"]
            payload = json.loads(body_raw) if isinstance(body_raw, str) else body_raw

            to_email, subject, text, html = _render_email(payload)
            send_mail(to_email, subject, text, html)
            print(f"Email enviado para {to_email} | video_id={payload.get('video_id')}")
        except Exception as e:
            print(f"Falha ao processar mensagem: {e}")
            raise
