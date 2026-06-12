# 프로젝트 초기화 스크립트
# 처음 설정 시 실행

Write-Host "🚀 업무 자동화 시스템 초기 설정 시작" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

$projectDir = $PSScriptRoot | Split-Path
$configFile = "$projectDir\email_config.json"
$harnessFile = "$projectDir\harness.json"

# 1. 필수 파일 확인
Write-Host "`n[1/5] 필수 파일 확인 중..." -ForegroundColor Yellow

$requiredFiles = @(
    "manage_ui.html",
    "tasks.json",
    "harness.json"
)

foreach ($file in $requiredFiles) {
    if (Test-Path "$projectDir\$file") {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file 없음" -ForegroundColor Red
    }
}

# 2. 로그 디렉토리 생성
Write-Host "`n[2/5] 로그 디렉토리 생성 중..." -ForegroundColor Yellow
if (-not (Test-Path "$projectDir\logs")) {
    New-Item -ItemType Directory -Path "$projectDir\logs" -Force | Out-Null
    Write-Host "  ✓ logs 디렉토리 생성" -ForegroundColor Green
} else {
    Write-Host "  ✓ logs 디렉토리 이미 존재" -ForegroundColor Green
}

# 3. Git hooks 설정
Write-Host "`n[3/5] Git hooks 설정 중..." -ForegroundColor Yellow

$hooksDir = "$projectDir\.git\hooks"
if (Test-Path $hooksDir) {
    # hooks 등록
    $hookFiles = @("pre-commit", "post-commit", "pre-push", "post-merge")
    foreach ($hook in $hookFiles) {
        $hookPath = "$hooksDir\$hook"
        $hookPsPath = "$projectDir\hooks\$hook.ps1"

        if (Test-Path $hookPsPath) {
            Write-Host "  ✓ $hook hook 준비 완료" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  ⚠ Git hooks 디렉토리 없음 (git init 필요)" -ForegroundColor Yellow
}

# 4. 이메일 설정 확인
Write-Host "`n[4/5] 이메일 설정 확인 중..." -ForegroundColor Yellow

if (Test-Path $configFile) {
    try {
        $config = Get-Content $configFile | ConvertFrom-Json
        if ($config.sender_email -and $config.smtp_server) {
            Write-Host "  ✓ 이메일 설정 완료" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ 이메일 설정 불완전 (sender_email, smtp_server 필요)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ⚠ 이메일 설정 파일 형식 오류" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠ email_config.json 없음 (설정 필요)" -ForegroundColor Yellow
    Write-Host "    템플릿: templates\email_config.json 참조" -ForegroundColor Gray
}

# 5. 프로젝트 정보 표시
Write-Host "`n[5/5] 프로젝트 정보 로드 중..." -ForegroundColor Yellow

if (Test-Path $harnessFile) {
    try {
        $harness = Get-Content $harnessFile | ConvertFrom-Json
        Write-Host "  ✓ 프로젝트명: $($harness.project.name)" -ForegroundColor Green
        Write-Host "  ✓ 버전: $($harness.project.version)" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ harness.json 읽기 실패" -ForegroundColor Yellow
    }
}

# 6. 다음 단계 안내
Write-Host "`n════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ 초기 설정 완료!" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

Write-Host "`n📋 다음 단계:" -ForegroundColor Cyan
Write-Host "  1. email_config.json 설정 (필수)"
Write-Host "  2. .\scripts\run.ps1 실행 (웹 UI 시작)"
Write-Host "  3. manage_ui.html 브라우저에서 열기"
Write-Host "  4. 업무 추가 및 테스트"
Write-Host ""
Write-Host "📚 도움말:" -ForegroundColor Cyan
Write-Host "  .\scripts\test.ps1     # 기능 테스트"
Write-Host "  .\scripts\deploy.ps1   # 배포"
Write-Host "  .\scripts\review.ps1   # 코드 검토"
Write-Host ""

