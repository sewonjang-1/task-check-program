# 웹 UI 실행 스크립트
# manage_ui.html을 기본 브라우저로 열기

Write-Host "🌐 업무 관리 시스템 시작" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

$projectDir = $PSScriptRoot | Split-Path
$htmlFile = "$projectDir\manage_ui.html"
$logFile = "$projectDir\logs\run_log.txt"

# 로그 디렉토리 생성
if (-not (Test-Path "$projectDir\logs")) {
    New-Item -ItemType Directory -Path "$projectDir\logs" -Force | Out-Null
}

# 파일 존재 확인
if (-not (Test-Path $htmlFile)) {
    Write-Host "✗ manage_ui.html을 찾을 수 없습니다: $htmlFile" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: manage_ui.html not found" -Encoding UTF8
    exit 1
}

# 파일을 URI로 변환
$uri = "file:///$($htmlFile -replace '\\', '/')"

Write-Host "`n✓ 파일: $htmlFile" -ForegroundColor Green
Write-Host "✓ 시간: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green

# 기본 브라우저로 열기
Write-Host "`n🔄 브라우저 시작 중..." -ForegroundColor Yellow

try {
    Start-Process $htmlFile
    Write-Host "✓ manage_ui.html 열었습니다" -ForegroundColor Green
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Started manage_ui.html" -Encoding UTF8
} catch {
    Write-Host "✗ 브라우저 시작 실패: $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: $_" -Encoding UTF8
    exit 1
}

Write-Host "`n════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "💡 팁:" -ForegroundColor Cyan
Write-Host "  • 업무 추가 탭에서 새 업무를 추가하세요"
Write-Host "  • 업무목록 탭에서 완료 상황을 확인하세요"
Write-Host "  • 진척도 탭에서 월별 진행 상황을 봅시다"
Write-Host "  • 매일 오후 5시에 미완료 업무 이메일 발송됩니다"
Write-Host ""

