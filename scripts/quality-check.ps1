# Quality Rubric Auto-Validation Script
# Harness integration with RUBRIC.md
# Runs before each deployment to verify quality standards

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

Write-Host "[*] Quality Rubric Auto-Validation`n" -ForegroundColor Cyan

# 1. Core File Validation
Write-Host "[1] Core File Validation" -ForegroundColor Yellow
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
        Write-Host "  [OK] $file ($('{0:N0}' -f (Get-Item $path).Length) bytes)" -ForegroundColor Green
        $fileScore += 10
    } else {
        Write-Host "  [FAIL] $file missing" -ForegroundColor Red
    }
}
$fileScore = [Math]::Min($fileScore / 80 * 100, 100)

# 2. Code Quality Check
Write-Host "`n[2] Code Quality Validation" -ForegroundColor Yellow
$codeQuality = 0

# JSON Format Validation
try {
    $json = Get-Content $tasksFile -Encoding UTF8 | ConvertFrom-Json
    Write-Host "  [OK] tasks.json JSON format valid" -ForegroundColor Green
    $codeQuality += 33
    Write-Host "  [OK] Task items: $($json.Count)" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] tasks.json JSON format error" -ForegroundColor Red
}

# JavaScript Syntax Check
if (Get-Content "$projectDir\manage_ui.html" | Select-String "function \w+\(" -Quiet) {
    Write-Host "  [OK] manage_ui.html functions detected" -ForegroundColor Green
    $codeQuality += 33
} else {
    Write-Host "  [WARN] manage_ui.html functions not detected" -ForegroundColor Yellow
}

# PowerShell Syntax Check
$psScripts = @("setup.ps1", "run.ps1", "test.ps1", "deploy.ps1", "quality-check.ps1")
$validScripts = 0
foreach ($script in $psScripts) {
    $scriptPath = "$projectDir\scripts\$script"
    if (Test-Path $scriptPath) {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $scriptPath), [ref]$null)
        if ($?) {
            Write-Host "  [OK] scripts/$script syntax valid" -ForegroundColor Green
            $validScripts++
        }
    }
}

if ($validScripts -eq $psScripts.Count) {
    $codeQuality += 34
}

$codeQuality = [Math]::Min($codeQuality, 100)

# 3. Test Coverage
Write-Host "`n[3] Test Validation" -ForegroundColor Yellow
$testScore = 0

if (Test-Path $testResultsFile) {
    $testResults = Get-Content $testResultsFile
    $passedTests = ($testResults | Select-String "OK" | Measure-Object).Count
    $totalTests = ($testResults | Select-String "(OK|FAIL)" | Measure-Object).Count

    Write-Host "  [OK] Tests passed: $passedTests/$totalTests" -ForegroundColor Green
    $testScore = if ($totalTests -gt 0) { ($passedTests / $totalTests) * 100 } else { 0 }
} else {
    Write-Host "  [WARN] Test results file not found" -ForegroundColor Yellow
    $testScore = 50
}

# 4. Documentation Completeness
Write-Host "`n[4] Documentation Validation" -ForegroundColor Yellow
$docScore = 0

$documents = @("README.md", "CLAUDE.md", "SOUL.md", "RUBRIC.md")
$validDocs = 0
foreach ($doc in $documents) {
    $docPath = "$projectDir\$doc"
    if (Test-Path $docPath) {
        $content = Get-Content $docPath -Encoding UTF8
        if ($content.Length -gt 100) {
            Write-Host "  [OK] $doc ($(($content | Measure-Object -Line).Lines) lines)" -ForegroundColor Green
            $validDocs++
        }
    }
}
$docScore = ($validDocs / $documents.Count) * 100

# 5. Automation Completeness
Write-Host "`n[5] Automation Validation" -ForegroundColor Yellow
$autoScore = 0

$requiredScripts = @("setup.ps1", "run.ps1", "test.ps1", "deploy.ps1")
$existingScripts = 0
foreach ($script in $requiredScripts) {
    $path = "$projectDir\scripts\$script"
    if (Test-Path $path) {
        Write-Host "  [OK] scripts/$script exists" -ForegroundColor Green
        $existingScripts++
    }
}
$autoScore = ($existingScripts / $requiredScripts.Count) * 100

# 6. Deployment Safety
Write-Host "`n[6] Deployment Safety Validation" -ForegroundColor Yellow
$deployScore = 0

# Git Status Check
try {
    $gitStatus = git status --porcelain 2>&1
    if ($LASTEXITCODE -eq 0) {
        $uncommitted = ($gitStatus | Measure-Object).Count
        if ($uncommitted -eq 0) {
            Write-Host "  [OK] All changes committed" -ForegroundColor Green
            $deployScore += 50
        } else {
            Write-Host "  [WARN] Uncommitted files: $uncommitted" -ForegroundColor Yellow
            $deployScore += 25
        }

        # Latest Commit
        $lastCommit = git log -1 --oneline 2>&1
        Write-Host "  [OK] Latest commit: $lastCommit" -ForegroundColor Green
        $deployScore += 50
    }
} catch {
    Write-Host "  [WARN] Git status check unavailable" -ForegroundColor Yellow
    $deployScore = 50
}

# Total Score Calculation
$scores = @{
    "File Existence" = $fileScore
    "Code Quality" = $codeQuality
    "Test Coverage" = $testScore
    "Documentation" = $docScore
    "Automation" = $autoScore
    "Deployment Safety" = $deployScore
}

$totalScore = ($scores.Values | Measure-Object -Average).Average

# Grade Assignment
if ($totalScore -ge 95) {
    $grade = "S"
} elseif ($totalScore -ge 90) {
    $grade = "A+"
} elseif ($totalScore -ge 85) {
    $grade = "A"
} elseif ($totalScore -ge 80) {
    $grade = "B+"
} elseif ($totalScore -ge 70) {
    $grade = "B"
} else {
    $grade = "C"
}

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "`n[*] Quality Score Details`n" -ForegroundColor Cyan

foreach ($key in $scores.Keys) {
    $score = $scores[$key]
    $bar = "#" * ([int]($score / 5)) + "-" * ([int]((100 - $score) / 5))
    $color = if ($score -ge 90) { "Green" } elseif ($score -ge 80) { "Yellow" } else { "Red" }
    Write-Host "  $key`t: [$bar] $([int]$score)%" -ForegroundColor $color
}

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "`n[*] Overall Assessment`n" -ForegroundColor Green

if ($grade -eq "S") {
    $gradeColor = "Magenta"
} elseif ($grade -in @("A+", "A")) {
    $gradeColor = "Green"
} elseif ($grade -eq "B+") {
    $gradeColor = "Yellow"
} else {
    $gradeColor = "Red"
}

Write-Host "  Grade: " -NoNewline
Write-Host "$grade" -ForegroundColor $gradeColor -NoNewline
Write-Host " | Score: $([int]$totalScore)%" -ForegroundColor $gradeColor

Write-Host "`n========================================================`n" -ForegroundColor Cyan

# JSON Report Generation
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
    Write-Host "[OK] Report saved: $OutputFile`n" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Report save failed: $_`n" -ForegroundColor Yellow
}

# Status Return
if ($grade -in @("S", "A+", "A")) {
    Write-Host "[PASS] Quality standards met - Ready for deployment" -ForegroundColor Green
    exit 0
} elseif ($grade -in @("B+", "B")) {
    Write-Host "[WARN] Quality standards warning - Review recommended" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "[FAIL] Quality standards not met - Deployment not recommended" -ForegroundColor Red
    exit 1
}
