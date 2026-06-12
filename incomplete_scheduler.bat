@echo off
REM 미완료 업무 보고서 생성 및 메일 발송 배치 파일
REM Windows Task Scheduler에서 매일 오후 5시에 실행

cd /d %~dp0

REM PowerShell 실행 정책 설정
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\incomplete_report_generator.ps1'"

REM 보고서 생성 대기
timeout /t 2

REM 메일 발송
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '.\incomplete_mailer.ps1'"

REM 완료
exit /b 0
