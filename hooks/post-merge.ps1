# Post-merge hook
# 병합 후 자동 설정

Write-Host "🔄 Post-merge 처리 시작..." -ForegroundColor Yellow

$projectDir = $PSScriptRoot | Split-Path -Parent

# 1. 변경된 파일 확인
Write-Host "  [1/2] 변경된 파일 확인" -ForegroundColor Gray

$changedFiles = git diff-tree -r --name-only -m -c HEAD@{1} HEAD 2>/dev/null

if ($changedFiles) {
    $fileCount = ($changedFiles | Measure-Object).Count
    Write-Host "    ✓ $fileCount 개 파일 변경됨" -ForegroundColor Green
}

# 2. 필수 파일 재검증
Write-Host "  [2/2] 필수 파일 재검증" -ForegroundColor Gray

$requiredFiles = @(
    "harness.json",
    "manage_ui.html",
    "tasks.json",
    "incomplete_report_generator.ps1",
    "incomplete_mailer.ps1"
)

$missingCount = 0
foreach ($file in $requiredFiles) {
    if (Test-Path "$projectDir\$file") {
        Write-Host "    ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "    ✗ $file 없음" -ForegroundColor Red
        $missingCount++
    }
}

if ($missingCount -eq 0) {
    Write-Host "`n✅ Post-merge 처리 완료" -ForegroundColor Green
} else {
    Write-Host "`n⚠ 일부 파일 누락 - 확인 필요" -ForegroundColor Yellow
}

exit 0
