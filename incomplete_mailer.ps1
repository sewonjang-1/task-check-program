# 미완료 업무 이메일 발송 스크립트
# incomplete_report_generator.ps1에서 생성한 보고서를 이메일로 발송

$configFile = "$PSScriptRoot\email_config.json"
$reportFile = "$PSScriptRoot\incomplete_report.html"
$logFile = "$PSScriptRoot\logs\incomplete_mail_log.txt"

# 로그 디렉토리 생성
if (-not (Test-Path "$PSScriptRoot\logs")) {
    New-Item -ItemType Directory -Path "$PSScriptRoot\logs" -Force | Out-Null
}

try {
    # 이메일 설정 로드
    $config = Get-Content $configFile | ConvertFrom-Json

    # 보고서 파일 확인
    if (-not (Test-Path $reportFile)) {
        throw "보고서 파일을 찾을 수 없습니다: $reportFile"
    }

    # 보고서 내용 읽기
    $htmlBody = Get-Content $reportFile -Encoding UTF8 -Raw

    # 이메일 설정
    $smtpServer = $config.smtp_server
    $smtpPort = $config.smtp_port
    $senderEmail = $config.sender_email
    $senderPassword = $config.sender_password
    $recipientEmail = $config.recipient_email

    # SMTP 클라이언트 설정
    $smtpClient = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtpClient.EnableSsl = $true
    $smtpClient.Credentials = New-Object System.Net.NetworkCredential($senderEmail, $senderPassword)

    # 이메일 메시지 생성
    $mailMessage = New-Object System.Net.Mail.MailMessage
    $mailMessage.From = $senderEmail
    $mailMessage.To.Add($recipientEmail)
    $mailMessage.Subject = "⚠️ 오늘 미완료 업무 알림 - $(Get-Date -Format 'yyyy년 MM월 dd일')"
    $mailMessage.Body = $htmlBody
    $mailMessage.IsBodyHtml = $true
    $mailMessage.BodyEncoding = [System.Text.Encoding]::UTF8
    $mailMessage.SubjectEncoding = [System.Text.Encoding]::UTF8

    # 이메일 발송
    $smtpClient.Send($mailMessage)

    # 로그 기록
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - 미완료 업무 메일 발송 성공: $recipientEmail"
    Add-Content -Path $logFile -Value $logMessage -Encoding UTF8

    Write-Host "✓ 미완료 업무 메일 발송 완료"
    Write-Host "✓ 수신자: $recipientEmail"
    Write-Host "✓ 발송 시간: $(Get-Date -Format 'HH:mm:ss')"
}
catch {
    # 에러 로그 기록
    $errorMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - 오류: $($_.Exception.Message)"
    Add-Content -Path $logFile -Value $errorMessage -Encoding UTF8

    Write-Host "✗ 미완료 업무 메일 발송 실패"
    Write-Host "✗ 오류: $($_.Exception.Message)"
    exit 1
}
