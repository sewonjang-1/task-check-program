# PowerShell 업무 수집 스크립트
# Claude 에이전트 비탑재 환경에서도 동작

param(
    [string]$Action = "summary",
    [string]$Category = $null,
    [string]$Month = $null,
    [string]$OutputFile = "daily_report.json"
)

$projectDir = $PSScriptRoot | Split-Path
$tasksFile = "$projectDir\tasks.json"

# 함수: tasks.json 로드
function Load-Tasks {
    if (-not (Test-Path $tasksFile)) {
        Write-Host "✗ tasks.json 없음" -ForegroundColor Red
        return @()
    }

    try {
        $json = Get-Content $tasksFile -Encoding UTF8 | ConvertFrom-Json
        return $json
    } catch {
        Write-Host "✗ JSON 파싱 실패: $_" -ForegroundColor Red
        return @()
    }
}

# 함수: 오늘 업무 수집
function Get-TodayTasks {
    param([array]$Tasks)

    $today = Get-Date -Format "yyyy-MM-dd"
    return $Tasks | Where-Object { $_.dueDate -eq $today }
}

# 함수: 미완료 업무
function Get-IncompleteTasks {
    param([array]$Tasks)

    return $Tasks | Where-Object { $_.status -ne "COMPLETED" }
}

# 함수: 월별 업무
function Get-TasksByMonth {
    param(
        [array]$Tasks,
        [string]$Month
    )

    return $Tasks | Where-Object { $_.dueDate -like "$Month*" }
}

# 함수: 카테고리별 업무
function Get-TasksByCategory {
    param(
        [array]$Tasks,
        [string]$Category
    )

    return $Tasks | Where-Object { $_.category -eq $Category }
}

# 함수: 진척도 계산
function Get-Progress {
    param(
        [array]$Tasks,
        [string]$Category = $null,
        [string]$Month = $null
    )

    $filtered = $Tasks

    if ($Category) {
        $filtered = $filtered | Where-Object { $_.category -eq $Category }
    }

    if ($Month) {
        $filtered = $filtered | Where-Object { $_.dueDate -like "$Month*" }
    }

    if ($filtered.Count -eq 0) {
        return @{
            total       = 0
            completed   = 0
            percentage  = 0
        }
    }

    $total = $filtered.Count
    $completed = ($filtered | Where-Object { $_.status -eq "COMPLETED" }).Count

    return @{
        total       = $total
        completed   = $completed
        percentage  = if ($total -gt 0) { [int]($completed / $total * 100) } else { 0 }
    }
}

# 함수: 보고서 생성
function New-Report {
    param(
        [array]$Tasks,
        [string]$OutputPath
    )

    $today = Get-Date -Format "yyyy-MM-dd"
    $todayTasks = Get-TodayTasks $Tasks
    $incompleteTodayTasks = $todayTasks | Where-Object { $_.status -ne "COMPLETED" }

    $categories = @($Tasks | Select-Object -ExpandProperty category -Unique)

    $categoryProgress = @{}
    foreach ($cat in $categories) {
        $categoryProgress[$cat] = Get-Progress $Tasks -Category $cat
    }

    $report = @{
        date          = $today
        generated_at  = (Get-Date -Format "o")
        summary       = @{
            total_today       = $todayTasks.Count
            incomplete_today  = $incompleteTodayTasks.Count
            total_incomplete  = (Get-IncompleteTasks $Tasks).Count
        }
        today_tasks   = $todayTasks
        incomplete    = $incompleteTodayTasks
        categories    = $categoryProgress
    }

    try {
        $json = $report | ConvertTo-Json -Depth 10
        Set-Content -Path $OutputPath -Value $json -Encoding UTF8
        return $report
    } catch {
        Write-Host "✗ 보고서 생성 실패: $_" -ForegroundColor Red
        return $null
    }
}

# 메인 로직
$tasks = Load-Tasks

Write-Host "📋 업무 수집 시스템`n" -ForegroundColor Cyan

switch ($Action) {
    "summary" {
        Write-Host "✓ 총 업무: $($tasks.Count)개" -ForegroundColor Green
        Write-Host "✓ 미완료: $((Get-IncompleteTasks $tasks).Count)개" -ForegroundColor Green

        $todayCount = (Get-TodayTasks $tasks).Count
        Write-Host "✓ 오늘: $todayCount개" -ForegroundColor Green

        $categories = @($tasks | Select-Object -ExpandProperty category -Unique)
        Write-Host "✓ 카테고리: $($categories.Count)개" -ForegroundColor Green
    }

    "today" {
        $todayTasks = Get-TodayTasks $tasks
        Write-Host "📌 오늘 업무 ($($todayTasks.Count)개):`n" -ForegroundColor Yellow

        foreach ($task in $todayTasks) {
            $status = if ($task.status -eq "COMPLETED") { "✓" } else { "○" }
            Write-Host "  $status $($task.category) > $($task.subcategory)"
        }
    }

    "incomplete" {
        $incomplete = Get-IncompleteTasks $tasks
        Write-Host "⚠ 미완료 업무 ($($incomplete.Count)개):`n" -ForegroundColor Red

        foreach ($task in $incomplete | Select-Object -First 10) {
            Write-Host "  ○ $($task.category) > $($task.subcategory)"
        }

        if ($incomplete.Count -gt 10) {
            Write-Host "  ... 외 $($incomplete.Count - 10)개"
        }
    }

    "report" {
        $report = New-Report $tasks $OutputFile
        if ($report) {
            Write-Host "✓ 보고서 생성: $OutputFile" -ForegroundColor Green
            Write-Host "  오늘 완료: $($report.summary.incomplete_today)/$($report.summary.total_today)" -ForegroundColor Gray
        }
    }

    "progress" {
        Write-Host "📊 진척도:`n" -ForegroundColor Cyan

        $categories = @($tasks | Select-Object -ExpandProperty category -Unique)
        foreach ($cat in $categories) {
            $prog = Get-Progress $tasks -Category $cat
            $bar = "█" * ($prog.percentage / 10) + "░" * (10 - ($prog.percentage / 10))
            Write-Host "  $cat $bar $($prog.percentage)% ($($prog.completed)/$($prog.total))"
        }
    }

    default {
        Write-Host "사용법: .\collect-tasks.ps1 -Action [summary|today|incomplete|report|progress]" -ForegroundColor Yellow
    }
}
