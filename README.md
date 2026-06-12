# 📋 업무 자동화 시스템 - 사용 가이드

**이 문서는 "어떻게 사용하는가"를 다룹니다.**
- 프로젝트 철학은 [SOUL.md](SOUL.md)
- Claude 협업 규칙은 [CLAUDE.md](CLAUDE.md)

---

## 🚀 3분 안에 시작하기

```powershell
# 1. 초기 설정
.\scripts\setup.ps1

# 2. 브라우저에서 웹 UI 실행
.\scripts\run.ps1

# 3. 업무 추가 후 사용
```

---

## 📖 사용 방법

### 웹 UI 5가지 탭

| 탭 | 용도 | 언제 |
|----|------|------|
| **📌 업무목록** | 오늘/주간/월간 업무 확인 & 완료 체크 | 매일 |
| **📊 진척도** | 대분류별 완료율 시각화 | 월말 |
| **➕ 새 업무 추가** | 새로운 업무 추가 | 필요시 |
| **📋 기존 업무 복사** | 지난달 업무 복사 → 이번달 추가 | 월초 |
| **💾 데이터 관리** | JSON 백업/복원 | 정기 백업 |

### 주요 기능

#### 1️⃣ 반복 업무 설정
```
새 업무 추가 → 반복 설정:
  □ 반복 안 함
  ☑ 매일 (daily)
  ☑ 매주 (weekly)
  ☑ 매달 (monthly)
```

#### 2️⃣ 월별 진척도 추적
```
진척도 탭 → 월 선택 → 대분류별 완료율 확인
```

#### 3️⃣ 데이터 백업
```
데이터 관리 탭 → 데이터 내보내기 → JSON 다운로드
```

---

## ⚙️ 자동화 스크립트

```powershell
.\scripts\setup.ps1    # 프로젝트 초기화 (처음 1회)
.\scripts\run.ps1      # 웹 UI 실행
.\scripts\test.ps1     # 기능 테스트 (배포 전)
.\scripts\deploy.ps1   # 테스트 + 커밋 + 푸시 (완전 자동)
```

### Git Hooks (자동 실행, 설정 불필요)
- **Pre-commit**: JSON/PowerShell 파일 자동 검증
- **Post-commit**: 커밋 정보 자동 로깅
- **Pre-push**: 테스트 실행 후 안전한 푸시
- **Post-merge**: 필수 파일 자동 확인

---

## 📧 이메일 설정 (선택사항)

### Gmail 설정 (추천)
1. Google 계정 → 보안 → 2단계 인증 활성화
2. 앱 비밀번호 생성 (Gmail 선택)
3. `email_config.json` 수정:
```json
{
  "smtp_server": "smtp.gmail.com",
  "smtp_port": 587,
  "sender_email": "your-email@gmail.com",
  "sender_password": "16자 앱 비밀번호",
  "recipient_email": "받을 이메일"
}
```
4. `.\setup_incomplete_scheduler.ps1` 실행

### 다른 메일 서버
```json
// Naver
"smtp_server": "smtp.naver.com"

// Kakao
"smtp_server": "smtp.kakao.com"

// Outlook
"smtp_server": "smtp-mail.outlook.com"
```

---

## 🐛 문제 해결

### 이메일이 안 나가요
→ `logs/incomplete_mail_log.txt` 확인 후 `test_incomplete_scheduler.bat` 테스트

### 데이터가 저장 안 되
→ 개발자도구 (F12) → Storage → localStorage → 'tasks' 키 확인

### Git 관련 오류
→ Git hooks 로그: `logs/git_hooks_log.txt`

---

## 📊 파일 구조

```
프로젝트/
├── 📄 manage_ui.html           # 웹 UI
├── 📄 tasks.json               # 업무 데이터
├── 📄 email_config.json        # 이메일 설정
├── 📄 harness.json             # 하네스 설정
│
├── 📁 scripts/                 # 자동화 스크립트
│   ├── setup.ps1
│   ├── run.ps1
│   ├── test.ps1
│   └── deploy.ps1
│
├── 📁 hooks/                   # Git hooks
│   └── (4개의 validation scripts)
│
└── 📁 logs/                    # 자동 생성
    ├── run_log.txt
    ├── test_results.txt
    ├── deploy_log.txt
    ├── git_hooks_log.txt
    └── incomplete_mail_log.txt
```

---

## 🎓 포함된 스킬

### 1. task-automation-system
웹 UI, 자동 이메일, 진척도 추적 시스템

### 2. code-review-automation
코드 검토 및 버그 식별 자동화

### 3. task-automation-workflow
전체 3단계 프로세스 통합 (구축 + 검토 + 수정)

📖 각 스킬의 상세 정보는 `.claude/skills/*/SKILL.md` 참조

---

## ✅ 일일 체크리스트

```
[ ] manage_ui.html 열기
[ ] 오늘 할 업무 확인
[ ] 완료한 업무 체크
[ ] 필요시 새 업무 추가
[ ] 오후 5시에 이메일 확인
[ ] 완료 후 페이지 새로고침
```

---

## 🔗 관련 문서
- [프로젝트 철학 & 원칙 → SOUL.md](SOUL.md)
- [Claude 협업 규칙 → CLAUDE.md](CLAUDE.md)
