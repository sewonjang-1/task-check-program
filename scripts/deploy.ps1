# 배포 스크립트
# GitHub에 변경사항 푸시

Write-Host "🚀 배포 시작" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

$projectDir = $PSScriptRoot | Split-Path
$deployLog = "$projectDir\logs\deploy_log.txt"

# 로그 시작
Add-Content -Path $deployLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - 배포 시작" -Encoding UTF8

Write-Host "`n[1/4] Git 상태 확인" -ForegroundColor Yellow
Set-Location $projectDir
$gitStatus = git status --porcelain

if ($gitStatus) {
    Write-Host "  변경사항 감지됨:" -ForegroundColor Green
    $gitStatus -split "`n" | Where-Object { $_ } | ForEach-Object {
        Write-Host "    $_" -ForegroundColor Gray
    }
} else {
    Write-Host "  변경사항 없음" -ForegroundColor Gray
}

Write-Host "`n[2/4] 테스트 실행" -ForegroundColor Yellow
try {
    & "$projectDir\scripts\test.ps1"
    Write-Host "  ✓ 테스트 통과" -ForegroundColor Green
    Add-Content -Path $deployLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - 테스트 통과" -Encoding UTF8
} catch {
    Write-Host "  ✗ 테스트 실패: $_" -ForegroundColor Red
    Add-Content -Path $deployLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - 테스트 실패: $_" -Encoding UTF8
    Write-Host "`n❌ 배포 실패 (테스트 실패)" -ForegroundColor Red
    exit 1
}

Write-Host "`n[3/4] 커밋 & 푸시" -ForegroundColor Yellow

# 변경사항이 있는 경우만 커밋
if ($gitStatus) {
    git add .
    git commit -m "chore: automated deployment at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "  ✓ 커밋 완료" -ForegroundColor Green
    Add-Content -Path $deployLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - 커밋 완료" -Encoding UTF8
} else {
    Write-Host "  ℹ 커밋할 변경사항 없음" -ForegroundColor Gray
}

Write-Host "`n[4/4] GitHub 푸시" -ForegroundColor Yellow
try {
    git push origin main
    Write-Host "  ✓ GitHub 푸시 완료" -ForegroundColor Green
    Add-Content -Path $deployLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - GitHub 푸시 완료" -Encoding UTF8
} catch {
    Write-Host "  ✗ 푸시 실패: $_" -ForegroundColor Red
    Add-Content -Path $deployLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - 푸시 실패: $_" -Encoding UTF8
    Write-Host "`n⚠ 배포 부분 실패 (푸시 실패)" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ 배포 완료!" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "`n📝 로그: $deployLog" -ForegroundColor Gray
Write-Host ""

