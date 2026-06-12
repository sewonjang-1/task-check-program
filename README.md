# 📋 업무 자동화 시스템

팀 전체의 업무를 체계적으로 관리하고, 자동으로 보고하는 완전한 시스템입니다.

## 🎯 핵심 기능

### 1️⃣ 웹 기반 업무 관리
- 📱 반응형 UI (대분류 → 소분류 → 상세내용)
- 📅 일일/주간/월간 자동 분류
- 📊 월별 진척도 시각화
- ♻️ 반복 업무 자동화 (일일/주간/월간)

### 2️⃣ 자동 이메일 보고
- ⏰ 매일 오후 5시 미완료 업무 자동 발송
- 📧 HTML 형식 정규 보고서
- 🔔 Task Scheduler 자동 등록

### 3️⃣ 데이터 관리
- 💾 JSON 기반 로컬 저장 (서버 불필요)
- 📥 데이터 내보내기/가져오기
- 🔒 에러 처리 & 데이터 검증

---

## 🚀 빠른 시작

### 1단계: 초기 설정
\\\powershell
.\scripts\setup.ps1
\\\

### 2단계: 웹 UI 실행
\\\powershell
.\scripts\run.ps1
\\\

### 3단계: 이메일 설정 (선택)
email_config.json 수정 후 setup_incomplete_scheduler.ps1 실행

### 4단계: 업무 추가
브라우저에서 manage_ui.html 열기 → "새 업무 추가" 탭

---

## 📚 하네스 명령어

### 설정 및 실행
\\\powershell
.\scripts\setup.ps1    # 초기 설정
.\scripts\run.ps1      # 웹 UI 실행
.\scripts\test.ps1     # 기능 테스트
.\scripts\deploy.ps1   # 배포 (테스트 + 커밋 + 푸시)
\\\

### Git Hooks (자동 실행)
- Pre-commit: JSON/PowerShell 검증
- Post-commit: 커밋 로그 기록
- Pre-push: 최종 검증 & 테스트
- Post-merge: 파일 재검증

---

## 📊 파일 구조

\\\
프로젝트/
├── manage_ui.html              # 웹 UI
├── tasks.json                  # 업무 데이터
├── email_config.json           # 이메일 설정
├── harness.json                # 하네스 설정
├── scripts/                    # 자동화 스크립트
├── hooks/                      # Git hooks
└── logs/                       # 실행 로그
\\\

---

## 🎓 포함된 스킬

1. **task-automation-system**: 시스템 구축
2. **code-review-automation**: 코드 검토
3. **task-automation-workflow**: 통합 워크플로우

---

**더 자세한 내용은 각 스킬의 SKILL.md 파일을 참조하세요!**
