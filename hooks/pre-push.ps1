# Pre-push hook
# 푸시 전 최종 검증

Write-Host "🔐 Pre-push 검증 시작..." -ForegroundColor Yellow

$projectDir = $PSScriptRoot | Split-Path -Parent
$exitCode = 0

# 1. 커밋 메시지 확인
Write-Host "  [1/3] 커밋 메시지 검증" -ForegroundColor Gray

$unpushedCommits = git log origin/main..HEAD --oneline 2>/dev/null
if ($unpushedCommits) {
    Write-Host "    발신 커밋 목록:" -ForegroundColor Green
    $unpushedCommits | ForEach-Object {
        Write-Host "      $_" -ForegroundColor Gray
    }
} else {
    Write-Host "    ✓ 발신 커밋 없음" -ForegroundColor Green
}

# 2. 로컬 테스트 실행
Write-Host "  [2/3] 로컬 테스트 실행" -ForegroundColor Gray

try {
    $testResult = & "$projectDir\scripts\test.ps1" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✓ 테스트 통과" -ForegroundColor Green
    } else {
        Write-Host "    ✗ 테스트 실패" -ForegroundColor Red
        $exitCode = 1
    }
} catch {
    Write-Host "    ⚠ 테스트 실행 오류: $_" -ForegroundColor Yellow
}

# 3. 변경사항 요약
Write-Host "  [3/3] 변경사항 요약" -ForegroundColor Gray

$diffStat = git diff --stat origin/main 2>/dev/null
if ($diffStat) {
    Write-Host "    $($diffStat.Count) 개 파일 변경" -ForegroundColor Green
} else {
    Write-Host "    변경사항 없음" -ForegroundColor Gray
}

# 결론
if ($exitCode -eq 0) {
    Write-Host "`n✅ Pre-push 검증 통과 (푸시 진행)" -ForegroundColor Green
} else {
    Write-Host "`n❌ Pre-push 검증 실패 (푸시 중단)" -ForegroundColor Red
}

exit $exitCode
