# Post-commit hook
# 커밋 후 로그 기록

$projectDir = $PSScriptRoot | Split-Path -Parent
$hookLogFile = "$projectDir\logs\git_hooks_log.txt"

# 로그 디렉토리 확인
if (-not (Test-Path "$projectDir\logs")) {
    New-Item -ItemType Directory -Path "$projectDir\logs" -Force | Out-Null
}

# 커밋 정보 로그
Write-Host "📝 커밋 로그 기록 중..." -ForegroundColor Gray

try {
    $commitHash = git rev-parse --short HEAD
    $commitMsg = git log -1 --pretty=%B
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $logEntry = @"
[$timestamp] 커밋 완료
  해시: $commitHash
  메시지: $commitMsg
  ---

"@

    Add-Content -Path $hookLogFile -Value $logEntry -Encoding UTF8
    Write-Host "  ✓ 커밋 로그 기록 완료" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ 로그 기록 실패: $_" -ForegroundColor Yellow
}

exit 0
