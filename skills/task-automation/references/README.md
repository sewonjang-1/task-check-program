# 📋 일일 업무 자동화 보고서 시스템

매일 오전 10시에 업무 보고서를 자동으로 생성하여 이메일로 발송하는 시스템입니다.

## 🚀 빠른 시작

### 1단계: 업무 관리

#### 방법 A: 웹 인터페이스 사용 (권장)
```
manage_ui.html 파일을 웹 브라우저에서 열어서 업무를 추가/수정/삭제합니다.
- 브라우저 localStorage에 데이터가 저장됩니다
- JSON 파일로 내보내기 기능은 별도 개발 필요
```

#### 방법 B: JSON 파일 직접 편집
`tasks.json` 파일을 메모장이나 VS Code로 열어서 직접 편집합니다.

```json
{
  "tasks": [
    {
      "id": 1,
      "title": "프로젝트 기획",
      "description": "새 프로젝트의 기획서 작성",
      "priority": "HIGH",
      "dueDate": "2026-06-12",
      "status": "PENDING"
    }
  ]
}
```

### 2단계: 이메일 설정

`email_config.json` 파일을 메모장으로 열어서 설정합니다:

```json
{
  "smtp_server": "smtp.gmail.com",
  "smtp_port": 587,
  "sender_email": "wireacc@dsr.com",
  "sender_password": "YOUR_APP_PASSWORD_HERE",
  "recipient_email": "wireacc@dsr.com"
}
```

#### Gmail 설정 (권장)
1. https://myaccount.google.com/apppasswords 방문
2. "앱 비밀번호" 생성
3. `sender_password` 필드에 입력

#### Naver 설정
```json
{
  "smtp_server": "smtp.naver.com",
  "smtp_port": 587,
  "sender_email": "your.naver@naver.com",
  "sender_password": "NAVER_APP_PASSWORD"
}
```

#### Kakao 설정
```json
{
  "smtp_server": "smtp.kakao.com",
  "smtp_port": 587,
  "sender_email": "your.kakao@kakao.com",
  "sender_password": "KAKAO_APP_PASSWORD"
}
```

### 3단계: 수동 테스트

#### PowerShell에서 실행
```powershell
cd "C:\Users\Admin\Desktop\2일차 과제-1"

# 보고서 생성만 테스트
.\report_generator.ps1 -ScriptPath "."

# 배치 파일로 전체 실행
.\scheduler.bat
```

### 4단계: 자동화 스케줄링 (Windows Task Scheduler)

#### 작업 스케줄러 설정
1. Windows에서 "작업 스케줄러" 검색하여 실행
2. "작업 만들기" 클릭

**일반 탭:**
- 이름: "일일 업무 보고서"
- 설명: "매일 10시에 업무 보고서 자동 발송"

**트리거 탭:**
- 새로 만들기
- 시간표: 매일
- 시간: 10:00
- 반복 간격: 매일

**작업 탭:**
- 프로그램: `cmd.exe`
- 인수 추가: `/c "C:\Users\Admin\Desktop\2일차 과제-1\scheduler.bat"`
- 시작 위치: `C:\Users\Admin\Desktop\2일차 과제-1`

**조건 탭:**
- "컴퓨터가 배터리로 실행 중인 경우에도 작업 시작" 체크

**설정 탭:**
- 작업이 실패하면 다시 시작 활성화

## 📁 파일 설명

| 파일명 | 설명 |
|--------|------|
| `tasks.json` | 업무 데이터 저장 (JSON 형식) |
| `email_config.json` | SMTP 설정 정보 |
| `report_generator.ps1` | HTML 보고서 생성 스크립트 |
| `mail_sender.ps1` | 이메일 발송 스크립트 |
| `scheduler.bat` | 두 스크립트를 순차 실행하는 배치 파일 |
| `manage_ui.html` | 업무 관리 웹 인터페이스 |
| `daily_report.html` | 생성된 보고서 (자동 생성) |
| `logs/mail_log.txt` | 이메일 발송 로그 |

## 🎯 업무 항목 설명

### 필수 필드
- **id**: 고유 번호 (중복 금지)
- **title**: 업무 제목
- **priority**: 우선순위 (HIGH, MEDIUM, LOW)
- **dueDate**: 기한 (YYYY-MM-DD 형식)

### 선택 필드
- **description**: 업무 설명
- **status**: 상태 (PENDING, COMPLETED)

## 📊 보고서 내용

매일 생성되는 보고서에 포함되는 내용:

1. **요약 통계**
   - 전체 업무 수
   - 완료된 업무 수
   - 진행중인 업무 수
   - 완료율

2. **카테고리별 업무 목록**
   - 📌 **오늘 할 것**: 오늘 기한인 업무
   - 📅 **주중에 할 것**: 내일~이번주 금요일까지의 업무
   - 📆 **월중에 할 것**: 다음주~이번달 말까지의 업무
   - 각 카테고리는 우선순위 순서로 정렬

3. **카테고리별 통계**
   - 각 카테고리별 업무 수
   - 각 카테고리별 완료 수
   - 우선순위별 개수

## 🔧 문제 해결

### 이메일이 발송되지 않는 경우

1. **인증 오류**
   - email_config.json의 비밀번호 확인
   - Gmail의 경우 [앱 비밀번호](https://myaccount.google.com/apppasswords) 확인

2. **로그 확인**
   - `logs/mail_log.txt` 파일에서 오류 메시지 확인

3. **수동 테스트**
   ```powershell
   cd "C:\Users\Admin\Desktop\2일차 과제-1"
   .\mail_sender.ps1 -ScriptPath "."
   ```

### PowerShell 실행 정책 오류

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 💡 팁

### 정기적인 백업
- `tasks.json` 파일을 정기적으로 백업하세요
- 클라우드 저장소(OneDrive, Google Drive 등)에 동기화 권장

### 카테고리 자동 분류
시스템은 **기한(dueDate)에 따라 자동으로 분류**합니다:

- **📌 오늘 할 것**: 오늘 날짜와 같은 업무
- **📅 주중에 할 것**: 내일부터 이번주 일요일까지의 업무
- **📆 월중에 할 것**: 다음주부터 이번달 말까지의 업무

### 우선순위 설정 가이드
- **HIGH (🔴)**: 오늘 반드시 완료해야 할 업무
- **MEDIUM (🟠)**: 주중 중 완료해야 할 업무
- **LOW (🟢)**: 언제든 완료 가능한 업무

### 정기 정리
- tasks.json 파일을 주 1회 정리하여 **완료된 업무 제거** 권장
- 또는 manage_ui.html의 웹 인터페이스에서 체크박스로 표시하여 관리

## 📝 업데이트 방법

시스템을 업그레이드하거나 수정하려면:

1. 기존 파일 백업
2. 새 파일로 교체
3. email_config.json 설정 유지
4. 테스트 후 배포

## 🆘 지원

문제가 발생하면:

1. `logs/mail_log.txt` 파일 확인
2. 이메일 설정 재확인
3. 배치 파일을 PowerShell에서 직접 실행해 보기
4. Windows 작업 스케줄러 로그 확인
