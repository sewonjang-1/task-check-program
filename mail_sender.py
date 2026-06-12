#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from pathlib import Path
from datetime import datetime
import sys

SCRIPT_DIR = Path(__file__).parent
CONFIG_FILE = SCRIPT_DIR / "email_config.json"
REPORT_FILE = SCRIPT_DIR / "daily_report.html"
LOG_FILE = SCRIPT_DIR / "logs" / "mail_log.txt"

def create_log_dir():
    """로그 디렉토리 생성"""
    log_dir = SCRIPT_DIR / "logs"
    log_dir.mkdir(exist_ok=True)

def log_message(message):
    """로그 메시지 작성"""
    create_log_dir()
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_entry = f"[{timestamp}] {message}\n"
    print(log_entry.strip())

    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(log_entry)

def load_config():
    """email_config.json 로드"""
    if not CONFIG_FILE.exists():
        log_message("❌ 오류: email_config.json 파일을 찾을 수 없습니다.")
        sys.exit(1)

    with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def load_report():
    """보고서 HTML 로드"""
    if not REPORT_FILE.exists():
        log_message("❌ 오류: 보고서 파일을 찾을 수 없습니다.")
        return None

    with open(REPORT_FILE, 'r', encoding='utf-8') as f:
        return f.read()

def send_email(config, html_content):
    """이메일 발송"""
    try:
        # 설정 확인
        if config['sender_password'] == 'YOUR_APP_PASSWORD_HERE':
            log_message("❌ 오류: email_config.json에서 sender_password를 설정해주세요.")
            return False

        # 메일 작성
        msg = MIMEMultipart('alternative')
        msg['Subject'] = config['email_subject'].format(
            date=datetime.now().strftime('%Y-%m-%d')
        )
        msg['From'] = config['sender_email']
        msg['To'] = config['recipient_email']

        # HTML 본문
        html_part = MIMEText(html_content, 'html', 'utf-8')
        msg.attach(html_part)

        # SMTP 연결 및 발송
        with smtplib.SMTP(config['smtp_server'], config['smtp_port'], timeout=10) as server:
            server.starttls()
            server.login(config['sender_email'], config['sender_password'])
            server.send_message(msg)

        log_message(f"✅ 이메일이 성공적으로 발송되었습니다. ({config['recipient_email']})")
        return True

    except smtplib.SMTPAuthenticationError:
        log_message("❌ 오류: 이메일 인증 실패. 사용자명/비밀번호를 확인하세요.")
        return False
    except smtplib.SMTPException as e:
        log_message(f"❌ 오류: SMTP 오류 - {str(e)}")
        return False
    except Exception as e:
        log_message(f"❌ 오류: {str(e)}")
        return False

def main():
    """메인 함수"""
    log_message("=" * 50)
    log_message("📨 일일 업무 보고서 이메일 발송 시작")

    # 설정 로드
    config = load_config()
    log_message(f"설정 로드 완료 (수신자: {config['recipient_email']})")

    # 보고서 로드
    html_content = load_report()
    if not html_content:
        log_message("❌ 보고서를 생성해주세요. (python report_generator.py 실행)")
        return False

    log_message("보고서 로드 완료")

    # 메일 발송
    success = send_email(config, html_content)
    log_message("=" * 50)
    return success

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
