# 📚 업무 자동화 스킬 설치 가이드

## 🎯 스킬 정보

- **이름**: task-automation
- **설명**: 매일 업무를 자동으로 정리하여 이메일로 발송하는 시스템
- **GitHub**: https://github.com/sewonjang-1/task-check-program

## 📦 설치 방법

### 방법 1: 스킬 파일 다운로드 (권장)

#### 1단계: 스킬 디렉토리 생성

```powershell
# Linux/Mac
mkdir -p ~/.claude/skills/task-automation

# Windows PowerShell
New-Item -ItemType Directory -Path "$env:APPDATA\Claude\skills\task-automation" -Force
```

#### 2단계: 파일 복사

GitHub 저장소에서 `skills/task-automation/` 디렉토리의 모든 파일을 위의 디렉토리에 복사합니다.

디렉토리 구조:
```
task-automation/
├── SKILL.md                      # 스킬 메타데이터 및 설명
├── evals/                        # 테스트 케이스
│   └── evals.json
├── scripts/                      # 초기화 스크립트
│   └── initialize_system.ps1
└── references/                   # 참고 자료
    ├── report_generator.ps1
    ├── mail_sender.ps1
    ├── manage_ui.html
    ├── daily_report.html
    └── README.md
```

#### 3단계: 스킬 사용

Claude Code에서 다음을 입력하면 스킬이 자동으로 트리거됩니다:

```
"업무 자동화 시스템을 만들어줄 수 있어?"
"매일 메일로 업무 보고서를 받고 싶어"
"일일 업무 관리 시스템을 설정해줘"
```

### 방법 2: Git 클론

```bash
cd ~/.claude/skills

git clone https://github.com/sewonjang-1/task-check-program.git temp-repo

cp -r temp-repo/skills/task-automation .

rm -rf temp-repo
```

## 🚀 스킬 사용하기

스킬이 설치되면 Claude Code에서 업무 자동화와 관련된 요청을 하면 자동으로 스킬이 실행됩니다.

### 예시 1: 기본 시스템 구축

```
사용자: "업무를 자동으로 정리해서 매일 메일로 받고 싶어. 
오늘, 주중, 월중으로 구분해서 보여줬으면 좋겠어."

스킬 응답:
- SKILL.md에서 시스템 구조 설명
- 초기화 스크립트 실행 방법 안내
- SMTP 설정 가이드 제공
- 웹 UI와 보고서 템플릿 제시
```

### 예시 2: Gmail 설정

```
사용자: "Gmail로 자동 메일을 보낼 수 있게 설정해줄래?"

스킬 응답:
- Gmail 앱 비밀번호 생성 방법
- email_config.json 설정 예제
- 테스트 방법 안내
```

### 예시 3: 업무 우선순위 관리

```
사용자: "HIGH, MEDIUM, LOW 우선순위로 업무를 관리하고 싶어"

스킬 응답:
- 우선순위 정의 설명
- 웹 UI에서 우선순위 설정 방법
- 보고서에서 우선순위별 표시 방법
```

## 📋 스킬이 제공하는 것

### SKILL.md
- 스킬의 기능 및 사용 시점 설명
- 5단계 빠른 시작 가이드
- 파일 구조 설명
- 업무 분류 규칙
- 우선순위 설정 가이드
- 문제 해결 방법

### scripts/initialize_system.ps1
프로젝트 디렉토리에서 실행하면 자동으로 생성:
- `tasks.json` - 업무 데이터 파일
- `email_config.json` - SMTP 설정 템플릿
- `report_generator.ps1` - 보고서 생성 스크립트
- `mail_sender.ps1` - 메일 발송 스크립트
- `scheduler.bat` - 자동화 배치 파일
- `manage_ui.html` - 웹 관리 인터페이스
- `daily_report.html` - 보고서 템플릿

### references/
- `report_generator.ps1` - PowerShell로 HTML 보고서 생성
- `mail_sender.ps1` - SMTP를 통한 이메일 발송
- `manage_ui.html` - 브라우저에서 업무 관리
- `daily_report.html` - 이메일로 발송할 보고서 형식
- `README.md` - 상세 설정 및 사용 가이드

### evals/evals.json
스킬의 성능을 검증하는 테스트 케이스:
1. 기본 시스템 구축 테스트
2. Gmail 설정 가이드 테스트
3. 웹 UI 및 우선순위 기능 테스트

## ⚙️ 스킬의 작동 방식

### 트리거 조건

스킬은 다음과 같은 사용자 입력에서 자동으로 트리거됩니다:

- "업무 자동화" 언급
- "일일 보고서" 언급
- "메일 자동화" 언급
- "일정 관리" 언급
- "자동 발송" 언급
- "매일 10시" 언급 (Task Scheduler 관련)

### 실행 흐름

1. **요구사항 파악**
   - 사용자가 원하는 기능 확인
   - 필요한 정보 수집

2. **시스템 설명**
   - SKILL.md의 내용을 바탕으로 설명
   - 사용 사례별 가이드 제공

3. **초기화 지원**
   - `initialize_system.ps1` 스크립트 사용 방법 안내
   - 자동으로 생성될 파일 목록 제시

4. **설정 지원**
   - SMTP 설정 가이드 제공
   - 이메일 서비스별 설정 예제

5. **검증**
   - 보고서 샘플 제시
   - 테스트 방법 안내

## 🔧 스킬 커스터마이징

### 스킬 수정

스킬의 SKILL.md를 수정하려면:

1. `~/.claude/skills/task-automation/SKILL.md` 편집
2. 변경 사항을 GitHub에 푸시하거나 로컬에만 유지

### 스킬 확장

새로운 기능을 추가하려면:

1. `scripts/` 또는 `references/` 디렉토리에 새 파일 추가
2. SKILL.md에서 해당 파일 참조
3. `evals/evals.json`에 테스트 케이스 추가

## 📞 지원

### 스킬 관련 문제

1. **스킬이 트리거되지 않음**
   - 키워드가 정확한지 확인
   - Claude Code 리로드

2. **파일 누락**
   - `references/` 디렉토리의 모든 파일 존재 확인
   - GitHub에서 최신 버전 다운로드

3. **설정 오류**
   - SKILL.md의 "문제 해결" 섹션 확인

### 시스템 관련 문제

시스템 실행 중 문제가 발생하면 `logs/mail_log.txt` 파일을 확인하세요.

## 📚 추가 자료

- **GitHub 저장소**: https://github.com/sewonjang-1/task-check-program
- **스킬 설명**: `SKILL.md` (스킬 내부)
- **상세 가이드**: `skills/task-automation/references/README.md`

## 🎉 완료!

스킬이 설치되었습니다. 이제 Claude Code에서 업무 자동화 관련 작업을 요청하면 스킬이 자동으로 도움을 줍니다!
