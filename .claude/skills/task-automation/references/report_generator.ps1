# UTF-8 인코딩 설정
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

param(
    [string]$ScriptPath = $PSScriptRoot
)

$ErrorActionPreference = "Continue"

$tasksFile = Join-Path $ScriptPath "tasks.json"
$reportFile = Join-Path $ScriptPath "daily_report.html"

function Get-TasksByDate {
    param(
        [array]$tasks,
        [datetime]$targetDate
    )

    $dateString = $targetDate.ToString("yyyy-MM-dd")
    return $tasks | Where-Object { $_.dueDate -eq $dateString }
}

function Get-TasksByDateRange {
    param(
        [array]$tasks,
        [datetime]$startDate,
        [datetime]$endDate
    )

    $result = @()
    $current = $startDate

    while ($current -le $endDate) {
        $dateString = $current.ToString("yyyy-MM-dd")
        $result += $tasks | Where-Object { $_.dueDate -eq $dateString }
        $current = $current.AddDays(1)
    }

    return $result
}

function Sort-TasksByPriority {
    param([array]$tasks)

    $priorityOrder = @{
        "HIGH" = 1
        "MEDIUM" = 2
        "LOW" = 3
    }

    return $tasks | Sort-Object { $priorityOrder[$_.priority] }
}

function Get-PriorityColor {
    param([string]$priority)

    switch ($priority) {
        "HIGH" { return "#ff6b6b" }
        "MEDIUM" { return "#ffa94d" }
        "LOW" { return "#69db7c" }
        default { return "#999" }
    }
}

function Get-PriorityIcon {
    param([string]$priority)

    switch ($priority) {
        "HIGH" { return "🔴" }
        "MEDIUM" { return "🟠" }
        "LOW" { return "🟢" }
        default { return "⭕" }
    }
}

# 메인 로직
try {
    # tasks.json 로드
    if (-not (Test-Path $tasksFile)) {
        Write-Host "오류: tasks.json 파일을 찾을 수 없습니다."
        exit 1
    }

    $data = Get-Content $tasksFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $allTasks = $data.tasks

    # 날짜 설정
    $today = Get-Date
    $tomorrow = $today.AddDays(1)
    $weekStart = $today
    $weekEnd = $today.AddDays(6)
    $nextWeekStart = $today.AddDays(7)
    $nextWeekEnd = $today.AddDays(13)

    # 날짜별 업무 필터링
    $todayTasks = Get-TasksByDate $allTasks $today
    $tomorrowTasks = Get-TasksByDate $allTasks $tomorrow
    $thisWeekTasks = Get-TasksByDateRange $allTasks $weekStart $weekEnd
    $nextWeekTasks = Get-TasksByDateRange $allTasks $nextWeekStart $nextWeekEnd

    # 통계 계산
    $totalTasks = $allTasks.Count
    $completedTasks = ($allTasks | Where-Object { $_.status -eq "COMPLETED" }).Count
    $pendingTasks = $totalTasks - $completedTasks
    $completionRate = if ($totalTasks -gt 0) { [int]($completedTasks / $totalTasks * 100) } else { 0 }

    # 오늘 업무 HTML 생성
    $todayHtml = ""
    $todayTasksSorted = Sort-TasksByPriority $todayTasks

    if ($todayTasksSorted.Count -gt 0) {
        foreach ($task in $todayTasksSorted) {
            $priorityColor = Get-PriorityColor $task.priority
            $priorityIcon = Get-PriorityIcon $task.priority
            $statusIcon = if ($task.status -eq "COMPLETED") { "✅" } else { "⭕" }

            $todayHtml += @"
            <div class="task-item" style="border-left: 4px solid $priorityColor">
                <div class="task-header">
                    <span class="status-icon">$statusIcon</span>
                    <span class="task-title">$($task.title)</span>
                    <span class="priority-badge">$priorityIcon $($task.priority)</span>
                </div>
                <div class="task-description">$($task.description)</div>
            </div>

"@
        }
    } else {
        $todayHtml = '<p style="color: #999; padding: 20px;">오늘 할당된 업무가 없습니다.</p>'
    }

    # 내일 업무 HTML
    $tomorrowHtml = ""
    if ($tomorrowTasks.Count -gt 0) {
        $tomorrowHtml = "<p>내일 예정된 업무: <strong>$($tomorrowTasks.Count)</strong>건</p>"
    }

    # 이번주 업무 HTML
    $thisWeekHtml = ""
    if ($thisWeekTasks.Count -gt 0) {
        $thisWeekHtml = "<p>이번주 예정된 업무: <strong>$($thisWeekTasks.Count)</strong>건</p>"
    }

    # 다음주 업무 HTML
    $nextWeekHtml = ""
    if ($nextWeekTasks.Count -gt 0) {
        $nextWeekHtml = "<p>다음주 예정된 업무: <strong>$($nextWeekTasks.Count)</strong>건</p>"
    }

    # 우선순위별 개수
    $highCount = ($allTasks | Where-Object { $_.priority -eq "HIGH" }).Count
    $mediumCount = ($allTasks | Where-Object { $_.priority -eq "MEDIUM" }).Count
    $lowCount = ($allTasks | Where-Object { $_.priority -eq "LOW" }).Count

    # 현재 날짜 포맷팅
    $now = Get-Date
    $dateStrKr = $now.ToString("yyyy년 MM월 dd일")

    # HTML 생성
    $htmlContent = @"
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일일 업무 보고서</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
            background: #f5f5f5;
            padding: 20px;
            color: #333;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .header h1 {
            font-size: 24px;
            margin-bottom: 10px;
        }

        .header p {
            font-size: 14px;
            opacity: 0.9;
        }

        .section {
            padding: 25px 30px;
            border-bottom: 1px solid #eee;
        }

        .section:last-child {
            border-bottom: none;
        }

        .section-title {
            font-size: 18px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .task-item {
            background: #f9f9f9;
            padding: 12px 15px;
            margin-bottom: 10px;
            border-radius: 6px;
            border-left: 4px solid #667eea;
        }

        .task-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 5px;
        }

        .status-icon {
            font-size: 16px;
        }

        .task-title {
            font-weight: 500;
            flex: 1;
        }

        .priority-badge {
            background: #f0f0f0;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 12px;
            white-space: nowrap;
        }

        .task-description {
            font-size: 13px;
            color: #666;
            margin-left: 26px;
        }

        .stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 15px;
        }

        .stat-box {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            border-radius: 6px;
            text-align: center;
        }

        .stat-number {
            font-size: 24px;
            font-weight: bold;
        }

        .stat-label {
            font-size: 12px;
            opacity: 0.9;
            margin-top: 5px;
        }

        .schedule-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }

        .schedule-item {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 6px;
            border-left: 3px solid #667eea;
        }

        .schedule-item p {
            margin: 5px 0;
            font-size: 14px;
        }

        .footer {
            background: #f5f5f5;
            padding: 15px 30px;
            text-align: center;
            font-size: 12px;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 일일 업무 보고서</h1>
            <p>$dateStrKr</p>
        </div>

        <div class="section">
            <div class="section-title">📊 요약 통계</div>
            <div class="stats">
                <div class="stat-box">
                    <div class="stat-number">$totalTasks</div>
                    <div class="stat-label">전체 업무</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">$completedTasks</div>
                    <div class="stat-label">완료</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">$pendingTasks</div>
                    <div class="stat-label">진행중</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">$completionRate%</div>
                    <div class="stat-label">완료율</div>
                </div>
            </div>
        </div>

        <div class="section">
            <div class="section-title">📌 오늘의 업무</div>
            $todayHtml
        </div>

        <div class="section">
            <div class="section-title">📅 기간별 예정</div>
            <div class="schedule-grid">
                <div class="schedule-item">
                    <p><strong>내일</strong></p>
                    $(if ($tomorrowHtml) { $tomorrowHtml } else { '<p style="color: #999;">예정된 업무 없음</p>' })
                </div>
                <div class="schedule-item">
                    <p><strong>이번주</strong></p>
                    $(if ($thisWeekHtml) { $thisWeekHtml } else { '<p style="color: #999;">예정된 업무 없음</p>' })
                </div>
                <div class="schedule-item">
                    <p><strong>다음주</strong></p>
                    $(if ($nextWeekHtml) { $nextWeekHtml } else { '<p style="color: #999;">예정된 업무 없음</p>' })
                </div>
                <div class="schedule-item">
                    <p><strong>우선순위</strong></p>
                    <p>HIGH: $highCount</p>
                    <p>MEDIUM: $mediumCount</p>
                    <p>LOW: $lowCount</p>
                </div>
            </div>
        </div>

        <div class="footer">
            <p>이 보고서는 자동으로 생성되었습니다. | 생성 시간: $(Get-Date -Format "HH:mm:ss")</p>
        </div>
    </div>
</body>
</html>
"@

    # 파일로 저장
    $htmlContent | Out-File -FilePath $reportFile -Encoding UTF8 -Force
    Write-Host "보고서가 생성되었습니다: $reportFile"

} catch {
    Write-Host "오류: $($_.Exception.Message)"
    exit 1
}
