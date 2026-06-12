---
name: task-automation
description: 매일 업무를 자동으로 정리하여 이메일로 발송하는 시스템 구축. 사용자가 "업무 자동화", "일일 보고서", "메일 자동화", "업무 관리", "일정 관리", "자동 이메일 발송" 등을 언급할 때 사용. 오늘/주중/월중 업무로 자동 분류하고, HTML 보고서 생성, SMTP를 통한 이메일 자동 발송, Windows Task Scheduler로 매일 10시 자동 실행 기능 포함.
---

# 업무 자동화 시스템

매일 업무를 자동으로 정리하여 이메일로 발송하는 완전한 시스템을 구축합니다.

## 🎯 기능

- **업무 관리**: 웹 인터페이스에서 업무 추가/수정/삭제
- **자동 분류**: 기한에 따라 오늘/주중/월중 업무로 자동 분류
- **보고서 생성**: 우선순위별 정렬된 HTML 보고서 자동 생성
- **이메일 발송**: SMTP를 통한 HTML 이메일 자동 발송
- **스케줄링**: Windows Task Scheduler로 매일 10시 자동 실행
- **통계**: 업무별 완료율, 우선순위 분석

## 📋 사용 시점

다음과 같은 상황에서 이 스킬을 사용하세요:

- 일일 업무를 자동으로 정리하고 싶을 때
- 매일 일정한 시간에 업무 현황을 이메일로 받고 싶을 때
- 업무를 우선순위별로 관리하고 싶을 때
- 오늘/주중/월중 업무로 구분하여 관리하고 싶을 때

## 🚀 빠른 시작

### 1단계: 초기 설정

프로젝트 디렉토리에서 다음 명령 실행:

```powershell
# 시스템 초기화 (모든 파일 자동 생성)
.\initialize_system.ps1
```

이 스크립트가 다음을 자동으로 수행합니다:
- ✓ `tasks.json` - 업무 데이터 파일 생성
- ✓ `email_config.json` - SMTP 설정 템플릿 생성
- ✓ `manage_ui.html` - 웹 관리 인터페이스 생성
- ✓ `report_generator.ps1` - 보고서 생성 스크립트 생성
- ✓ `mail_sender.ps1` - 메일 발송 스크립트 생성
- ✓ `scheduler.bat` - 자동화 배치 파일 생성

### 2단계: SMTP 설정

`email_config.json` 파일을 메모장으로 열어서 수정:

```json
{
  "smtp_server": "smtp.gmail.com",
  "smtp_port": 587,
  "sender_email": "your-email@gmail.com",
  "sender_password": "YOUR_APP_PASSWORD_HERE"
}
```

**Gmail의 경우:**
1. https://myaccount.google.com/apppasswords 방문
2. 2단계 인증 후 앱 비밀번호 생성
3. 생성된 비밀번호를 `sender_password`에 입력

**Naver/Kakao의 경우:**
- Naver: `smtp.naver.com:587`
- Kakao: `smtp.kakao.com:587`

### 3단계: 업무 추가

**웹 인터페이스 사용 (권장):**
```
manage_ui.html을 브라우저에서 열기
→ "새 업무 추가" 폼에서 업무 입력
→ 브라우저 localStorage에 자동 저장
```

**JSON 직접 편집:**
```json
{
  "tasks": [
    {
      "id": 1,
      "title": "프로젝트 기획",
      "description": "새로운 프로젝트 기획서 작성",
      "priority": "HIGH",
      "dueDate": "2026-06-12",
      "status": "PENDING"
    }
  ]
}
```

### 4단계: 테스트

PowerShell에서 수동 실행:
```powershell
cd C:\your\project\path
.\scheduler.bat
```

### 5단계: 자동화 (Windows Task Scheduler)

1. Windows에서 "작업 스케줄러" 검색
2. "작업 만들기" 클릭
3. **트리거 탭**: 매일 10:00 설정
4. **작업 탭**:
   - 프로그램: `cmd.exe`
   - 인수: `/c "C:\your\project\path\scheduler.bat"`

## 📊 파일 구조

```
your-project/
├── tasks.json                 # 업무 데이터 (JSON)
├── email_config.json         # SMTP 설정
├── report_generator.ps1      # 보고서 생성 스크립트
├── mail_sender.ps1           # 메일 발송 스크립트
├── scheduler.bat             # 자동화 배치 파일
├── manage_ui.html            # 웹 관리 인터페이스
├── daily_report.html         # 생성된 보고서
└── logs/                      # 실행 로그
    └── mail_log.txt
```

## 📌 업무 분류 규칙

시스템이 자동으로 분류합니다:

| 분류 | 범위 | 예시 |
|------|------|------|
| 📌 오늘 | 오늘 날짜 | 2026-06-12 |
| 📅 주중 | 내일~이번주 일요일 | 2026-06-13 ~ 06-18 |
| 📆 월중 | 다음주~이번달 말 | 2026-06-19 ~ 06-30 |

## 🎨 보고서 형식

생성되는 이메일 보고서에 포함되는 내용:

1. **요약 통계**
   - 전체 업무 수 / 완료 수 / 진행중 수 / 완료율

2. **오늘의 업무** (📌)
   - 오늘 기한인 업무들을 우선순위 순서로 표시

3. **주중의 업무** (📅)
   - 주중 기한인 업무들 정렬

4. **월중의 업무** (📆)
   - 월중 기한인 업무들 정렬

5. **통계**
   - 카테고리별 업무 수, 완료 수
   - 우선순위별 업무 개수

## ⚙️ 우선순위 설정 가이드

| 우선순위 | 아이콘 | 의미 | 사용 예시 |
|---------|--------|------|----------|
| HIGH | 🔴 | 오늘 반드시 완료 | 중요 회의, 긴급 버그 수정 |
| MEDIUM | 🟠 | 주중 중 완료 | 일반 업무, 코드 리뷰 |
| LOW | 🟢 | 월중 완료 | 백로그, 개선 작업 |

## 🔧 문제 해결

### 이메일이 발송되지 않음

1. **로그 확인**
   ```
   logs/mail_log.txt에서 오류 메시지 확인
   ```

2. **SMTP 설정 확인**
   - email_config.json의 비밀번호 재확인
   - Gmail: 앱 비밀번호 확인
   - 방화벽/안티바이러스 체크

3. **수동 테스트**
   ```powershell
   .\mail_sender.ps1
   ```

### PowerShell 실행 정책 오류

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 💡 팁

### 업무 상태 관리
- 웹 UI의 체크박스로 업무 완료 표시
- 또는 `tasks.json`의 `status` 필드를 `COMPLETED`로 변경

### 정기 백업
- `tasks.json`을 OneDrive/Google Drive에 동기화

### 수동 실행
```powershell
# 보고서만 생성
.\report_generator.ps1

# 전체 프로세스 실행
.\scheduler.bat
```

## 📞 지원

문제가 발생하면:
1. `logs/mail_log.txt` 확인
2. `email_config.json` 설정 재확인
3. 배치 파일을 PowerShell에서 직접 실행

---

**더 자세한 설정 가이드**: 프로젝트 디렉토리의 README.md를 참고하세요.
