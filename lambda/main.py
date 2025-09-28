import os
import smtplib
from email.message import EmailMessage
from datetime import datetime
from typing import Tuple
import requests
import logging
import json

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "level": record.levelname.lower(),
            "message": record.getMessage(),
            "logger": record.name,
            "time": self.formatTime(record, self.datefmt),
        }
        return json.dumps(log_record)


handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())

log = logging.getLogger(__name__)
log.setLevel(logging.INFO)
log.addHandler(handler)


MAILTRAP_HOST = os.environ.get("MAILTRAP_HOST", "smtp.mailtrap.io")
MAILTRAP_PORT = int(os.environ.get("MAILTRAP_PORT", "2525"))
MAILTRAP_USER = os.environ["MAILTRAP_USER"]
MAILTRAP_PASS = os.environ["MAILTRAP_PASS"]
FROM_EMAIL = os.environ.get("FROM_EMAIL", "no-reply@hackathon.com")
SUBJECT_PREFIX = os.environ.get("SUBJECT_PREFIX", "[Video Service] ")
user_service_endpoint = os.environ.get("USER_SERVICE_ENDPOINT")



def get_user_email(user_id):
    url = f"{user_service_endpoint}/api/v1/users/{user_id}"
    log.info(f"Getting user email from {url}")
    response = requests.get(url)
    user_email = None
    if response.status_code == 200:
        user_email = response.json()["email"]
        log.info(f"User email is {user_email}")
    else:
        log.error(f"Failed to get user email: {response.status_code} - {response.text}")
    return user_email


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


def _render_email(payload: dict) -> Tuple[str, str, str]:
    video_id = payload.get("video_id", "N/A")
    user_id = payload.get("user_id", "N/A")
    status = payload.get("status", "UPDATED")
    occurred_at = payload.get("occurred_at", datetime.now())

    email = get_user_email(user_id)
    if not email:
        raise Exception("No email address found")

    subject = f"Your video {video_id} has been updated!"
    text = f"Hello!\n\nYour video {video_id} has been updated to: {status} at {occurred_at}."

    return email, subject, text


def lambda_handler(event, context):
    try:
        body_raw = event.Message
        payload = json.loads(body_raw) if isinstance(body_raw, str) else body_raw
        log.info(f"message received: {payload}")

        to_email, subject, text = _render_email(payload)
        send_mail(to_email, subject, text)
        log.info(f"email sent to {to_email} | video_id={payload.get('video_id')}")
    except Exception as e:
        log.error(f"Fail to send email, Error: {e}")
