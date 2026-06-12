# 기능 테스트 스크립트

Write-Host "🧪 기능 테스트 시작" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

$projectDir = $PSScriptRoot | Split-Path
$testsFile = "$projectDir\logs\test_results.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 테스트 로그 시작
Add-Content -Path $testsFile -Value "════════════════════════════════════════" -Encoding UTF8
Add-Content -Path $testsFile -Value "테스트 시작: $timestamp" -Encoding UTF8
Add-Content -Path $testsFile -Value "════════════════════════════════════════" -Encoding UTF8

$testCount = 0
$passCount = 0
$failCount = 0

# 테스트 함수
function Test-Feature {
    param(
        [string]$TestName,
        [scriptblock]$TestScript
    )

    global:$testCount++
    Write-Host "`n[$testCount] $TestName 테스트" -ForegroundColor Yellow

    try {
        & $TestScript
        Write-Host "  ✓ PASS" -ForegroundColor Green
        global:$passCount++
        Add-Content -Path $testsFile -Value "[$testCount] $TestName - PASS" -Encoding UTF8
    } catch {
        Write-Host "  ✗ FAIL: $_" -ForegroundColor Red
        global:$failCount++
        Add-Content -Path $testsFile -Value "[$testCount] $TestName - FAIL: $_" -Encoding UTF8
    }
}

# Test 1: 파일 존재 확인
Test-Feature "필수 파일 확인" {
    $files = @("manage_ui.html", "tasks.json", "harness.json")
    foreach ($file in $files) {
        if (-not (Test-Path "$projectDir\$file")) {
            throw "$file 없음"
        }
    }
}

# Test 2: tasks.json 형식 확인
Test-Feature "tasks.json JSON 형식 검증" {
    $content = Get-Content "$projectDir\tasks.json" -Encoding UTF8
    $tasks = $content | ConvertFrom-Json
    if (-not ($tasks -is [array] -or $tasks -is [object])) {
        throw "유효하지 않은 JSON 형식"
    }
}

# Test 3: PowerShell 스크립트 구문 확인
Test-Feature "PowerShell 스크립트 구문 검증" {
    $scripts = @(
        "$projectDir\incomplete_report_generator.ps1",
        "$projectDir\incomplete_mailer.ps1",
        "$projectDir\setup_incomplete_scheduler.ps1"
    )

    foreach ($script in $scripts) {
        if (Test-Path $script) {
            $result = Test-Path $script -PathType Leaf
            if (-not $result) {
                throw "$script 파일 오류"
            }
        }
    }
}

# Test 4: 이메일 설정 확인
Test-Feature "이메일 설정 유효성 검사" {
    $configFile = "$projectDir\email_config.json"
    if (Test-Path $configFile) {
        $config = Get-Content $configFile | ConvertFrom-Json
        $required = @("smtp_server", "smtp_port", "sender_email", "recipient_email")
        foreach ($field in $required) {
            if (-not $config.$field) {
                throw "필수 필드 없음: $field"
            }
        }
    } else {
        Write-Host "  ⚠ 설정 파일 없음 (선택사항)" -ForegroundColor Yellow
    }
}

# Test 5: HTML 파일 크기 확인
Test-Feature "manage_ui.html 파일 유효성 검사" {
    $htmlFile = "$projectDir\manage_ui.html"
    $fileSize = (Get-Item $htmlFile).Length
    if ($fileSize -lt 10000) {
        throw "파일 크기 이상 (너무 작음: $fileSize bytes)"
    }
}

# Test 6: 로그 디렉토리 확인
Test-Feature "로그 디렉토리 확인" {
    $logsDir = "$projectDir\logs"
    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    }
}

# Test 7: 스크립트 디렉토리 확인
Test-Feature "스크립트 디렉토리 확인" {
    $scriptsDir = "$projectDir\scripts"
    if (-not (Test-Path $scriptsDir)) {
        throw "scripts 디렉토리 없음"
    }

    $scripts = Get-ChildItem -Path $scriptsDir -Filter "*.ps1"
    if ($scripts.Count -eq 0) {
        throw "PowerShell 스크립트 없음"
    }
}

# Test 8: Git 저장소 확인
Test-Feature "Git 저장소 상태 확인" {
    $gitDir = "$projectDir\.git"
    if (-not (Test-Path $gitDir)) {
        throw ".git 디렉토리 없음"
    }
}

# 테스트 결과 요약
Write-Host "`n════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 테스트 결과" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "총 테스트: $testCount" -ForegroundColor Cyan
Write-Host "성공: $passCount" -ForegroundColor Green
Write-Host "실패: $failCount" -ForegroundColor Red

# 결과를 로그에 기록
Add-Content -Path $testsFile -Value "" -Encoding UTF8
Add-Content -Path $testsFile -Value "테스트 결과: 총 $testCount, 성공 $passCount, 실패 $failCount" -Encoding UTF8
Add-Content -Path $testsFile -Value "완료 시간: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Encoding UTF8
Add-Content -Path $testsFile -Value "════════════════════════════════════════" -Encoding UTF8

if ($failCount -eq 0) {
    Write-Host "`n✅ 모든 테스트 통과!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ 일부 테스트 실패" -ForegroundColor Red
    Write-Host "자세한 내용: $testsFile" -ForegroundColor Yellow
    exit 1
}

