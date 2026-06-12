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
