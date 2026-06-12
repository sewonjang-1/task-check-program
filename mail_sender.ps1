# 이메일 발송 스크립트
param(
    [string]$ScriptPath = $PSScriptRoot
)

$ErrorActionPreference = "Continue"

$configFile = Join-Path $ScriptPath "email_config.json"
$reportFile = Join-Path $ScriptPath "daily_report.html"
$logsDir = Join-Path $ScriptPath "logs"
$logFile = Join-Path $logsDir "mail_log.txt"

function Write-Log {
    param([string]$Message)

    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
}

function Send-EmailReport {
    try {
        # 설정 로드
        if (-not (Test-Path $configFile)) {
            Write-Log "❌ 오류: email_config.json 파일을 찾을 수 없습니다."
            return $false
        }

        $config = Get-Content $configFile -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Log "설정 로드 완료 (수신자: $($config.recipient_email))"

        # 보고서 로드
        if (-not (Test-Path $reportFile)) {
            Write-Log "❌ 오류: 보고서 파일을 찾을 수 없습니다."
            return $false
        }

        $htmlContent = Get-Content $reportFile -Raw -Encoding UTF8
        Write-Log "보고서 로드 완료"

        # 비밀번호 확인
        if ($config.sender_password -eq "YOUR_APP_PASSWORD_HERE") {
            Write-Log "❌ 오류: email_config.json에서 sender_password를 설정해주세요."
            return $false
        }

        # 메일 전송 설정
        $SMTPServer = $config.smtp_server
        $SMTPPort = $config.smtp_port
        $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
        $SMTPClient.EnableSsl = $true
        $SMTPClient.Timeout = 10000

        # 인증 정보
        $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($config.sender_email, $config.sender_password)

        # 이메일 메시지 작성
        $MailMessage = New-Object System.Net.Mail.MailMessage
        $MailMessage.From = $config.sender_email
        $MailMessage.To.Add($config.recipient_email)
        $MailMessage.Subject = $config.email_subject -replace "{date}", (Get-Date -Format "yyyy-MM-dd")
        $MailMessage.Body = $htmlContent
        $MailMessage.IsBodyHtml = $true
        $MailMessage.BodyEncoding = [System.Text.Encoding]::UTF8

        # 메일 발송
        $SMTPClient.Send($MailMessage)
        $SMTPClient.Dispose()
        $MailMessage.Dispose()

        Write-Log "✅ 이메일이 성공적으로 발송되었습니다. ($($config.recipient_email))"
        return $true

    } catch {
        $errorMessage = $_.Exception.Message
        if ($errorMessage -like "*authentication*" -or $errorMessage -like "*credentials*") {
            Write-Log "❌ 오류: 이메일 인증 실패. 사용자명/비밀번호를 확인하세요."
        } else {
            Write-Log "❌ 오류: $errorMessage"
        }
        return $false
    }
}

# 메인
Write-Log "=================================================="
Write-Log "📨 일일 업무 보고서 이메일 발송 시작"

$success = Send-EmailReport

Write-Log "=================================================="

if ($success) {
    exit 0
} else {
    exit 1
}
