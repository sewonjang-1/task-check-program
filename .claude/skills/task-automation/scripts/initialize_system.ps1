# 업무 자동화 시스템 초기화 스크립트
# 사용법: .\initialize_system.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Continue"

Write-Host "=================================================="
Write-Host "  업무 자동화 시스템 초기화"
Write-Host "=================================================="
Write-Host ""

# 현재 디렉토리
$projectDir = (Get-Location).Path
Write-Host "프로젝트 디렉토리: $projectDir" -ForegroundColor Cyan

# 로그 디렉토리 생성
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" -Force | Out-Null
    Write-Host "✓ logs 디렉토리 생성"
}

# 1. tasks.json 생성
if (-not (Test-Path "tasks.json")) {
    $tasksJson = @{
        tasks = @(
            @{
                id = 1
                title = "프로젝트 기획서 작성"
                description = "새로운 프로젝트의 기획서를 작성하고 검토받기"
                priority = "HIGH"
                dueDate = (Get-Date).ToString("yyyy-MM-dd")
                status = "PENDING"
            },
            @{
                id = 2
                title = "회의 준비"
                description = "오후 3시 회의 자료 준비 및 검토"
                priority = "HIGH"
                dueDate = (Get-Date).ToString("yyyy-MM-dd")
                status = "PENDING"
            },
            @{
                id = 3
                title = "이메일 답변"
                description = "미처리 이메일에 대한 답변"
                priority = "MEDIUM"
                dueDate = (Get-Date).ToString("yyyy-MM-dd")
                status = "PENDING"
            },
            @{
                id = 4
                title = "팀 보고서 검토"
                description = "팀원들의 주간 보고서 검토"
                priority = "MEDIUM"
                dueDate = (Get-Date).AddDays(3).ToString("yyyy-MM-dd")
                status = "PENDING"
            },
            @{
                id = 5
                title = "고객 피드백 분석"
                description = "최근 고객 피드백 수집 및 분석"
                priority = "MEDIUM"
                dueDate = (Get-Date).AddDays(5).ToString("yyyy-MM-dd")
                status = "PENDING"
            },
            @{
                id = 6
                title = "코드 리뷰"
                description = "팀의 Pull Request 코드 리뷰"
                priority = "LOW"
                dueDate = (Get-Date).AddDays(13).ToString("yyyy-MM-dd")
                status = "PENDING"
            }
        )
    } | ConvertTo-Json -Depth 10

    $tasksJson | Out-File -FilePath "tasks.json" -Encoding UTF8
    Write-Host "✓ tasks.json 생성"
}

# 2. email_config.json 생성
if (-not (Test-Path "email_config.json")) {
    $emailConfig = @{
        smtp_server = "smtp.gmail.com"
        smtp_port = 587
        sender_email = "your-email@gmail.com"
        sender_password = "YOUR_APP_PASSWORD_HERE"
        recipient_email = "your-email@gmail.com"
        email_subject = "📋 오늘의 업무 보고서 - {date}"
        notes = @{
            gmail = "Gmail 사용 시: 2단계 인증 후 '앱 비밀번호' 생성 필요 (https://myaccount.google.com/apppasswords)"
            naver = "Naver 사용 시: smtp.naver.com:587, 앱 비밀번호 사용"
            kakao = "Kakao 사용 시: smtp.kakao.com:587, 앱 비밀번호 사용"
        }
    } | ConvertTo-Json -Depth 10

    $emailConfig | Out-File -FilePath "email_config.json" -Encoding UTF8
    Write-Host "✓ email_config.json 생성"
}

# 3. report_generator.ps1 복사
$skillDir = Split-Path (Split-Path $PSScriptRoot)
$reportGenSrc = Join-Path $skillDir "references" "report_generator.ps1"
if (Test-Path $reportGenSrc) {
    Copy-Item -Path $reportGenSrc -Destination "report_generator.ps1" -Force
    Write-Host "✓ report_generator.ps1 복사"
} else {
    Write-Host "⚠ report_generator.ps1을 수동으로 생성해주세요" -ForegroundColor Yellow
}

# 4. mail_sender.ps1 복사
$mailSenderSrc = Join-Path $skillDir "references" "mail_sender.ps1"
if (Test-Path $mailSenderSrc) {
    Copy-Item -Path $mailSenderSrc -Destination "mail_sender.ps1" -Force
    Write-Host "✓ mail_sender.ps1 복사"
} else {
    Write-Host "⚠ mail_sender.ps1을 수동으로 생성해주세요" -ForegroundColor Yellow
}

# 5. scheduler.bat 생성
if (-not (Test-Path "scheduler.bat")) {
    $batContent = @"
@echo off
chcp 65001 > nul
cd /d "%~dp0"

echo.
echo ================================================
echo  일일 업무 보고서 자동화 시스템
echo  실행 시간: %date% %time%
echo ================================================
echo.

REM 보고서 생성
echo [1/2] 보고서 생성 중...
powershell -ExecutionPolicy Bypass -File "%~dp0report_generator.ps1" -ScriptPath "%~dp0"
if %errorlevel% neq 0 (
    echo 보고서 생성 실패
    exit /b 1
)

REM 메일 발송
echo.
echo [2/2] 이메일 발송 중...
powershell -ExecutionPolicy Bypass -File "%~dp0mail_sender.ps1" -ScriptPath "%~dp0"
if %errorlevel% neq 0 (
    echo 이메일 발송 실패
    exit /b 1
)

echo.
echo ================================================
echo  모든 작업이 완료되었습니다.
echo ================================================
echo.
"@
    $batContent | Out-File -FilePath "scheduler.bat" -Encoding ASCII
    Write-Host "✓ scheduler.bat 생성"
}

# 6. manage_ui.html 복사
$htmlSrc = Join-Path $skillDir "references" "manage_ui.html"
if (Test-Path $htmlSrc) {
    Copy-Item -Path $htmlSrc -Destination "manage_ui.html" -Force
    Write-Host "✓ manage_ui.html 복사"
} else {
    Write-Host "⚠ manage_ui.html을 수동으로 생성해주세요" -ForegroundColor Yellow
}

# 7. daily_report.html 복사
$reportSrc = Join-Path $skillDir "references" "daily_report.html"
if (Test-Path $reportSrc) {
    Copy-Item -Path $reportSrc -Destination "daily_report.html" -Force
    Write-Host "✓ daily_report.html 복사"
} else {
    Write-Host "⚠ daily_report.html을 수동으로 생성해주세요" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=================================================="
Write-Host "  초기화 완료! 🎉"
Write-Host "=================================================="
Write-Host ""
Write-Host "다음 단계:"
Write-Host "  1. email_config.json 파일을 열어 SMTP 설정 입력"
Write-Host "  2. manage_ui.html을 브라우저에서 열어 업무 추가"
Write-Host "  3. .\scheduler.bat 실행하여 테스트"
Write-Host "  4. Windows Task Scheduler에서 매일 10시 자동 실행 설정"
Write-Host ""
