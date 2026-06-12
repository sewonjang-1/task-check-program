@echo off
REM 미완료 업무 메일 발송 테스트 배치 파일
REM 즉시 실행하여 설정이 정상인지 확인

color 0A
echo.
echo ════════════════════════════════════════
echo   미완료 업무 메일 발송 테스트
echo ════════════════════════════════════════
echo.

cd /d %~dp0

echo [1/2] 미완료 업무 보고서 생성 중...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\incomplete_report_generator.ps1'"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ✗ 보고서 생성 실패!
    pause
    exit /b 1
)

echo.
echo [2/2] 메일 발송 중...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\incomplete_mailer.ps1'"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ✗ 메일 발송 실패!
    echo.
    echo 다음을 확인하세요:
    echo - email_config.json이 있는지 확인
    echo - SMTP 설정이 올바른지 확인
    echo - 인터넷 연결 확인
    pause
    exit /b 1
)

echo.
echo ════════════════════════════════════════
echo ✅ 테스트 완료!
echo ════════════════════════════════════════
echo.
echo 📧 메일이 발송되었습니다.
echo 📝 로그 확인: logs\incomplete_mail_log.txt
echo 📄 보고서 확인: incomplete_report.html
echo.
pause
