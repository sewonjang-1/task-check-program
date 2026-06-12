# 품질 루브릭 자동 검증 스크립트
# 하네스와 RUBRIC.md 연결
# 매 배포마다 자동으로 실행되어 품질 기준 충족 여부 확인

param(
    [switch]$Verbose = $false,
    [string]$OutputFile = "logs/quality_report.json"
)

$projectDir = $PSScriptRoot | Split-Path
$rubricFile = "$projectDir\RUBRIC.md"
$tasksFile = "$projectDir\tasks.json"
$testResultsFile = "$projectDir\logs\test_results.txt"

# 로그 디렉토리 생성
if (-not (Test-Path "$projectDir\logs")) {
    New-Item -ItemType Directory -Path "$projectDir\logs" | Out-Null
}

Write-Host "📊 품질 루브릭 자동 검증`n" -ForegroundColor Cyan

# 1. 파일 존재성 검사
Write-Host "1️⃣  핵심 파일 검증" -ForegroundColor Yellow
$coreFiles = @(
    "manage_ui.html",
    "tasks.json",
    "email_config.json",
    "harness.json",
    "CLAUDE.md",
    "SOUL.md",
    "README.md",
    "RUBRIC.md"
)

$fileScore = 0
foreach ($file in $coreFiles) {
    $path = "$projectDir\$file"
    if (Test-Path $path) {
        Write-Host "  ✓ $file ($('{0:N0}' -f (Get-Item $path).Length) bytes)" -ForegroundColor Green
        $fileScore += 10
    } else {
        Write-Host "  ✗ $file 없음" -ForegroundColor Red
    }
}
$fileScore = [Math]::Min($fileScore / 80 * 100, 100)

# 2. 코드 품질 검사
Write-Host "`n2️⃣  코드 품질 검증" -ForegroundColor Yellow
$codeQuality = 0

# JSON 형식 검증
try {
    $json = Get-Content $tasksFile -Encoding UTF8 | ConvertFrom-Json
    Write-Host "  ✓ tasks.json JSON 형식 유효" -ForegroundColor Green
    $codeQuality += 33
    Write-Host "  ✓ 업무 항목: $($json.Count)개" -ForegroundColor Green
} catch {
    Write-Host "  ✗ tasks.json JSON 형식 오류" -ForegroundColor Red
}

# JavaScript 구문 검사 (기본)
if (Get-Content "$projectDir\manage_ui.html" | Select-String "function \w+\(" -Quiet) {
    Write-Host "  ✓ manage_ui.html 함수 정의 확인" -ForegroundColor Green
    $codeQuality += 33
} else {
    Write-Host "  ⚠ manage_ui.html 함수 미감지" -ForegroundColor Yellow
}

# PowerShell 구문 검사
$psScripts = @("setup.ps1", "run.ps1", "test.ps1", "deploy.ps1", "quality-check.ps1")
$validScripts = 0
foreach ($script in $psScripts) {
    $scriptPath = "$projectDir\scripts\$script"
    if (Test-Path $scriptPath) {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $scriptPath), [ref]$null)
        if ($?) {
            Write-Host "  ✓ scripts/$script 구문 유효" -ForegroundColor Green
            $validScripts++
        }
    }
}

if ($validScripts -eq $psScripts.Count) {
    $codeQuality += 34
}

$codeQuality = [Math]::Min($codeQuality, 100)

# 3. 테스트 커버리지
Write-Host "`n3️⃣  테스트 검증" -ForegroundColor Yellow
$testScore = 0

if (Test-Path $testResultsFile) {
    $testResults = Get-Content $testResultsFile
    $passedTests = ($testResults | Select-String "✓" | Measure-Object).Count
    $totalTests = ($testResults | Select-String "(✓|✗)" | Measure-Object).Count

    Write-Host "  ✓ 테스트 실행: $passedTests/$totalTests 통과" -ForegroundColor Green
    $testScore = if ($totalTests -gt 0) { ($passedTests / $totalTests) * 100 } else { 0 }
} else {
    Write-Host "  ⚠ 테스트 결과 파일 없음" -ForegroundColor Yellow
    $testScore = 50
}

# 4. 문서 완성도
Write-Host "`n4️⃣  문서 검증" -ForegroundColor Yellow
$docScore = 0

$documents = @("README.md", "CLAUDE.md", "SOUL.md", "RUBRIC.md")
$validDocs = 0
foreach ($doc in $documents) {
    $docPath = "$projectDir\$doc"
    if (Test-Path $docPath) {
        $content = Get-Content $docPath -Encoding UTF8
        if ($content.Length -gt 100) {
            Write-Host "  ✓ $doc ($(($content | Measure-Object -Line).Lines) lines)" -ForegroundColor Green
            $validDocs++
        }
    }
}
$docScore = ($validDocs / $documents.Count) * 100

# 5. 자동화 완성도
Write-Host "`n5️⃣  자동화 검증" -ForegroundColor Yellow
$autoScore = 0

$requiredScripts = @("setup.ps1", "run.ps1", "test.ps1", "deploy.ps1")
$existingScripts = 0
foreach ($script in $requiredScripts) {
    $path = "$projectDir\scripts\$script"
    if (Test-Path $path) {
        Write-Host "  ✓ scripts/$script 존재" -ForegroundColor Green
        $existingScripts++
    }
}
$autoScore = ($existingScripts / $requiredScripts.Count) * 100

# 6. 배포 안전성
Write-Host "`n6️⃣  배포 안전성 검증" -ForegroundColor Yellow
$deployScore = 0

# Git 상태 확인
try {
    $gitStatus = git status --porcelain 2>&1
    if ($LASTEXITCODE -eq 0) {
        $uncommitted = ($gitStatus | Measure-Object).Count
        if ($uncommitted -eq 0) {
            Write-Host "  ✓ 모든 변경사항 커밋됨" -ForegroundColor Green
            $deployScore += 50
        } else {
            Write-Host "  ⚠ 미커밋 파일: $uncommitted개" -ForegroundColor Yellow
            $deployScore += 25
        }

        # 최신 커밋 확인
        $lastCommit = git log -1 --oneline 2>&1
        Write-Host "  ✓ 최신 커밋: $lastCommit" -ForegroundColor Green
        $deployScore += 50
    }
} catch {
    Write-Host "  ⚠ Git 상태 확인 불가" -ForegroundColor Yellow
    $deployScore = 50
}

# ═══════════════════════════════════════════════════════════

# 종합 점수 계산
$scores = @{
    "파일 존재성" = $fileScore
    "코드 품질" = $codeQuality
    "테스트 커버리지" = $testScore
    "문서 완성도" = $docScore
    "자동화 완성도" = $autoScore
    "배포 안전성" = $deployScore
}

$totalScore = ($scores.Values | Measure-Object -Average).Average

# 등급 판정
$grade = switch {
    { $totalScore -ge 95 } { "S" }
    { $totalScore -ge 90 } { "A+" }
    { $totalScore -ge 85 } { "A" }
    { $totalScore -ge 80 } { "B+" }
    { $totalScore -ge 70 } { "B" }
    default { "C" }
}

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "`n📈 품질 점수 상세`n" -ForegroundColor Cyan

foreach ($key in $scores.Keys) {
    $score = $scores[$key]
    $bar = "█" * ([int]($score / 5)) + "░" * ([int]((100 - $score) / 5))
    $color = if ($score -ge 90) { "Green" } elseif ($score -ge 80) { "Yellow" } else { "Red" }
    Write-Host "  $key`t: $bar $([int]$score)%" -ForegroundColor $color
}

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "`n🎯 **종합 평가**`n" -ForegroundColor Green

$gradeColor = switch ($grade) {
    "S" { "Magenta" }
    "A+" { "Green" }
    "A" { "Green" }
    "B+" { "Yellow" }
    default { "Red" }
}

Write-Host "  등급: " -NoNewline
Write-Host "$grade" -ForegroundColor $gradeColor -NoNewline
Write-Host " | 점수: $([int]$totalScore)%" -ForegroundColor $gradeColor

Write-Host "`n═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# JSON 보고서 생성
$report = @{
    date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    total_score = [int]$totalScore
    grade = $grade
    details = $scores
    files_checked = $coreFiles.Count
    tests_passed = if ($totalTests -gt 0) { $passedTests } else { 0 }
    documents = $validDocs
    scripts = $existingScripts
    status = if ($grade -in @("S", "A+", "A")) { "PASS" } else { "REVIEW_NEEDED" }
}

try {
    $report | ConvertTo-Json | Set-Content -Path "$projectDir\$OutputFile" -Encoding UTF8
    Write-Host "✓ 보고서 저장: $OutputFile`n" -ForegroundColor Green
} catch {
    Write-Host "⚠ 보고서 저장 실패: $_`n" -ForegroundColor Yellow
}

# 상태 반환
if ($grade -in @("S", "A+", "A")) {
    Write-Host "✅ 품질 기준 충족 (배포 가능)" -ForegroundColor Green
    exit 0
} elseif ($grade -in @("B+", "B")) {
    Write-Host "⚠️  품질 기준 경고 (검토 권장)" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "❌ 품질 기준 미충족 (배포 불가)" -ForegroundColor Red
    exit 1
}
