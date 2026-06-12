# Task Scheduler 자동 설정 스크립트
# 매일 오후 5시에 미완료 업무 메일 발송하도록 작업 등록

# 관리자 권한 확인
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "✗ 관리자 권한이 필요합니다."
    Write-Host "이 스크립트를 관리자 권한으로 실행하세요."
    exit 1
}

$scriptPath = $PSScriptRoot
$batchFile = "$scriptPath\incomplete_scheduler.bat"
$taskName = "미완료 업무 메일 발송 (오후 5시)"
$taskFolder = "\업무자동화\"

Write-Host "════════════════════════════════════════"
Write-Host "  Task Scheduler 자동 설정"
Write-Host "════════════════════════════════════════"
Write-Host ""

# 기존 작업 삭제 (있으면)
$existingTask = Get-ScheduledTask -TaskPath $taskFolder -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "📌 기존 작업을 제거합니다..."
    Unregister-ScheduledTask -TaskPath $taskFolder -TaskName $taskName -Confirm:$false
    Start-Sleep -Seconds 1
}

# 새 작업 등록
Write-Host "📌 새 작업을 등록합니다..."

# 트리거 설정 (매일 오후 5시)
$trigger = New-ScheduledTaskTrigger `
    -Daily `
    -At "17:00"

# 작업 설정
$action = New-ScheduledTaskAction `
    -Execute $batchFile `
    -WorkingDirectory $scriptPath

# 기타 설정
$principal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive `
    -RunLevel Highest

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -WakeToRun `
    -MultipleInstances IgnoreNew

# 작업 등록
Register-ScheduledTask `
    -TaskPath $taskFolder `
    -TaskName $taskName `
    -Trigger $trigger `
    -Action $action `
    -Principal $principal `
    -Settings $settings `
    -Force | Out-Null

Write-Host "✅ 작업이 등록되었습니다!"
Write-Host ""
Write-Host "📋 작업 정보:"
Write-Host "  • 작업명: $taskName"
Write-Host "  • 폴더: $taskFolder"
Write-Host "  • 실행 시간: 매일 오후 5시 (17:00)"
Write-Host "  • 실행 배치: $batchFile"
Write-Host ""

# 작업 확인
Write-Host "🔍 작업 확인 중..."
$task = Get-ScheduledTask -TaskPath $taskFolder -TaskName $taskName
if ($task) {
    Write-Host "✅ 작업이 정상적으로 등록되었습니다!"
    Write-Host ""
    Write-Host "📊 작업 상세 정보:"
    Write-Host "  • 상태: $($task.State)"
    Write-Host "  • 마지막 실행: $($task.LastRunTime)"
    Write-Host "  • 다음 실행: $($task.NextRunTime)"
} else {
    Write-Host "✗ 작업 등록에 실패했습니다."
    exit 1
}

Write-Host ""
Write-Host "════════════════════════════════════════"
Write-Host "✅ 설정이 완료되었습니다!"
Write-Host "════════════════════════════════════════"
Write-Host ""
Write-Host "💡 테스트 방법:"
Write-Host "  1. PowerShell을 관리자 권한으로 열기"
Write-Host "  2. 다음 명령 실행: cd '$scriptPath'; .\incomplete_scheduler.bat"
Write-Host ""
Write-Host "📝 로그 확인:"
Write-Host "  $scriptPath\logs\incomplete_mail_log.txt"
Write-Host ""
