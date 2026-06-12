---
name: task-automation-system
description: |
  업무 자동화 시스템 구축. HTML 기반 업무 관리 웹UI, 일일 자동 이메일 보고서, 월별 진척도 추적, 반복 업무 자동화를 포함합니다. 
  
  **언제 사용**: 팀원들의 일일 업무를 체계적으로 추적하고, 완료 현황을 자동으로 보고받거나, 업무별 진행 상황을 월별로 모니터링하고 싶을 때 사용하세요.
  
  **포함 기능**:
  - 웹 UI (HTML/JavaScript): 대분류→소분류→상세내용 3단계 계층적 업무 관리
  - 일일 자동 보고: 미완료 업무를 오후 5시에 HTML 이메일로 자동 발송 (Windows Task Scheduler)
  - 월별 진척도: 대분류별 완료율 시각화
  - 반복 업무: 일일/주간/월간 자동 반복 설정
  - 데이터 관리: JSON 기반 로컬 저장, 내보내기/가져오기 기능
compatibility: 
  - Windows 11 Pro 이상 (Task Scheduler 필요)
  - PowerShell 5.0 이상
  - SMTP 가능한 메일 서버 (Gmail, Naver, Kakao 등)
---

# 업무 자동화 시스템

이 스킬을 사용하면 팀의 일일 업무 관리와 자동 보고 시스템을 5분 내에 완성할 수 있습니다.

## 🎯 핵심 기능

### 1️⃣ 웹 UI 기반 업무 관리

대분류 (예: 부가세신고)
  └─ 소분류 (예: 수출)
      └─ 상세내용 (예: 선적일 확인하기)

**특징**:
- 📱 반응형 웹 인터페이스 (브라우저에서 사용)
- ☑️ 소분류 단위 완료/미완료 체크
- 📅 날짜별 업무 자동 그룹화
- 💾 localStorage 기반 로컬 저장 (서버 없음)
- ♻️ 일일/주간/월간 반복 업무 자동화

### 2️⃣ 일일 자동 메일 보고 (오후 5시)

**특징**:
- ⏰ Windows Task Scheduler로 자동 실행
- 📊 HTML 이메일로 미완료 업무만 표시
- 🎨 우선순위별 색상 코딩
- 🔔 매일 오후 5시에 발송

### 3️⃣ 월별 진척도 추적

**특징**:
- 📈 대분류별 완료율 시각화
- 🗓️ 월별 선택 가능
- 🎯 진행 상황 한눈에 파악

## 📁 설치 및 사용

### 빠른 시작

1. GitHub에서 프로젝트 클론
2. email_config.json 수정
3. PowerShell을 관리자 권한으로 실행: setup_incomplete_scheduler.ps1
4. manage_ui.html을 브라우저로 열기

### 파일 구조

project/
├── manage_ui.html                 # 웹 UI (메인 인터페이스)
├── tasks.json                     # 업무 데이터
├── email_config.json              # 이메일 설정
├── incomplete_report_generator.ps1 # 미완료 보고서 생성
├── incomplete_mailer.ps1          # 이메일 발송
├── incomplete_scheduler.bat       # 자동화 배치 파일
├── setup_incomplete_scheduler.ps1 # Task Scheduler 자동 설정
└── logs/                          # 발송 로그

## 💡 설정 가이드

### Gmail 앱 비밀번호 설정
1. Google 계정 → 보안 → 2단계 인증 활성화
2. 앱 비밀번호 생성 (Gmail 선택)
3. 생성된 16자 비밀번호를 email_config.json에 입력

### 문제 해결

**메일이 안 나갈 때**
1. email_config.json 설정 확인
2. 로그 확인: logs/incomplete_mail_log.txt
3. 테스트 실행: test_incomplete_scheduler.bat

**Task Scheduler에 작업이 등록 안 될 때**
1. PowerShell을 관리자 권한으로 실행
2. 기존 작업 확인: Get-ScheduledTask -TaskPath "\업무자동화\"

## 📚 참고

- 🔗 GitHub 저장소: https://github.com/sewonjang-1/task-check-program
- 📖 상세 설정 가이드: INCOMPLETE_SETUP_GUIDE.md 참조

**최근 업데이트**: 2026-06-12
- ✨ 월별 진척도 추적 기능 추가
- 🎨 UI 개선 및 색상 코딩 강화
- 🔧 Task Scheduler 자동 설정 스크립트 개선
