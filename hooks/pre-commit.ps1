# Pre-commit hook
# 커밋 전에 코드 검증

Write-Host "🔍 Pre-commit 검증 시작..." -ForegroundColor Yellow

$projectDir = $PSScriptRoot | Split-Path -Parent
$exitCode = 0

# 1. 파일 크기 확인
Write-Host "  [1/3] 파일 크기 검증" -ForegroundColor Gray
$largeFiles = Get-ChildItem -Recurse -Path $projectDir | Where-Object {
    $_.Length -gt 10MB -and $_.FullName -notmatch "node_modules|\.git"
}

if ($largeFiles) {
    Write-Host "    ⚠ 큰 파일 감지:" -ForegroundColor Yellow
    $largeFiles | ForEach-Object {
        Write-Host "      - $($_.Name) ($('{0:N2}' -f ($_.Length / 1MB)) MB)" -ForegroundColor Yellow
    }
}

# 2. JSON 파일 검증
Write-Host "  [2/3] JSON 파일 검증" -ForegroundColor Gray
$jsonFiles = Get-ChildItem -Recurse -Path $projectDir -Filter "*.json"

foreach ($file in $jsonFiles) {
    try {
        Get-Content $file -Encoding UTF8 | ConvertFrom-Json | Out-Null
        Write-Host "    ✓ $($file.Name)" -ForegroundColor Green
    } catch {
        Write-Host "    ✗ $($file.Name): $_" -ForegroundColor Red
        $exitCode = 1
    }
}

# 3. PowerShell 스크립트 검증
Write-Host "  [3/3] PowerShell 스크립트 검증" -ForegroundColor Gray
$psScripts = Get-ChildItem -Recurse -Path $projectDir -Filter "*.ps1" | Where-Object {
    $_.FullName -match "scripts|hooks|setup"
}

foreach ($script in $psScripts) {
    try {
        [System.Management.Automation.PSParser]::Tokenize((Get-Content $script.FullName), [ref]$null) | Out-Null
        Write-Host "    ✓ $($script.Name)" -ForegroundColor Green
    } catch {
        Write-Host "    ✗ $($script.Name): $_" -ForegroundColor Red
        $exitCode = 1
    }
}

if ($exitCode -eq 0) {
    Write-Host "`n✅ Pre-commit 검증 통과" -ForegroundColor Green
} else {
    Write-Host "`n❌ Pre-commit 검증 실패" -ForegroundColor Red
}

exit $exitCode
