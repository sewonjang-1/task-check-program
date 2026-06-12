# 미완료 업무 보고서 생성 스크립트
# 오늘 해야할 일 중 하지 못한 내역을 HTML 보고서로 생성

$tasksFile = "$PSScriptRoot\tasks.json"
$reportFile = "$PSScriptRoot\incomplete_report.html"
$logFile = "$PSScriptRoot\logs\report_generator_log.txt"

# 로그 디렉토리 생성
if (-not (Test-Path "$PSScriptRoot\logs")) {
    New-Item -ItemType Directory -Path "$PSScriptRoot\logs" -Force | Out-Null
}

# tasks.json 파일 확인
if (-not (Test-Path $tasksFile)) {
    Write-Host "✗ tasks.json을 찾을 수 없습니다: $tasksFile"
    Write-Host "  먼저 manage_ui.html에서 업무를 추가하세요"
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: tasks.json not found" -Encoding UTF8
    exit 1
}

# JSON 로드
try {
    $tasks = Get-Content $tasksFile -Encoding UTF8 | ConvertFrom-Json
    if (-not $tasks) {
        $tasks = @()
    }
} catch {
    Write-Host "✗ tasks.json 파일 형식이 잘못되었습니다: $_"
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: Invalid JSON format - $_" -Encoding UTF8
    exit 1
}

# 오늘 날짜
$today = Get-Date
$todayDate = $today.ToString("yyyy-MM-dd")

# 오늘 미완료 업무 필터링
$incompleteTasks = $tasks.tasks | Where-Object {
    $_.dueDate -eq $todayDate -and $_.status -eq "PENDING"
}

# HTML 생성
$html = @"
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>미완료 업무 알림</title>
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
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%);
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

        .content {
            padding: 30px;
        }

        .section-title {
            font-size: 18px;
            font-weight: bold;
            color: #ff6b6b;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .stats {
            background: #fff3f3;
            border-left: 4px solid #ff6b6b;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }

        .stats p {
            margin: 5px 0;
            font-size: 14px;
        }

        .task-list {
            margin-bottom: 20px;
        }

        .category-group {
            margin-bottom: 20px;
        }

        .category-header {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%);
            color: white;
            padding: 10px 15px;
            border-radius: 6px;
            font-weight: bold;
            margin-bottom: 10px;
            font-size: 14px;
        }

        .task-item {
            background: #fafafa;
            padding: 12px 15px;
            margin-bottom: 10px;
            border-radius: 6px;
            border-left: 4px solid #ff6b6b;
        }

        .task-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 5px;
        }

        .task-title {
            font-weight: 500;
            flex: 1;
        }

        .priority-badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 11px;
            white-space: nowrap;
            font-weight: 500;
        }

        .priority-high {
            background: #ff6b6b;
            color: white;
        }

        .priority-medium {
            background: #ffa94d;
            color: white;
        }

        .priority-low {
            background: #69db7c;
            color: white;
        }

        .footer {
            background: #f5f5f5;
            padding: 15px 30px;
            text-align: center;
            font-size: 12px;
            color: #999;
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #999;
        }

        .empty-state h2 {
            font-size: 24px;
            margin-bottom: 10px;
            color: #69db7c;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⚠️ 오늘 미완료 업무 알림</h1>
            <p>$($today.ToString("yyyy년 MM월 dd일 (ddd요일)"))</p>
        </div>

        <div class="content">
"@

if ($incompleteTasks.Count -eq 0) {
    $html += @"
            <div class="empty-state">
                <h2>🎉 완료!</h2>
                <p>오늘 해야할 모든 업무를 완료했습니다!</p>
            </div>
"@
} else {
    $html += @"
            <div class="section-title">📌 미완료 업무</div>

            <div class="stats">
                <p><strong>총 미완료:</strong> $($incompleteTasks.Count)개</p>
                <p style="color: #999; font-size: 12px; margin-top: 8px;">빨리 완료하고 퇴근하세요! 💪</p>
            </div>

            <div class="task-list">
"@

    # 대분류별로 그룹화
    $grouped = $incompleteTasks | Group-Object -Property category

    foreach ($group in $grouped) {
        $category = $group.Name
        $html += @"
                <div class="category-group">
                    <div class="category-header">🏷️ $category</div>
"@

        foreach ($task in $group.Group) {
            $priorityClass = "priority-$($task.priority.ToLower())"
            $priorityText = @{ HIGH = "높음"; MEDIUM = "중간"; LOW = "낮음" }[$task.priority]
            $html += @"
                    <div class="task-item">
                        <div class="task-header">
                            <span class="task-title">$($task.subcategory) - $($task.title)</span>
                            <span class="priority-badge $priorityClass">$priorityText</span>
                        </div>
                    </div>
"@
        }

        $html += @"
                </div>
"@
    }

    $html += @"
            </div>
"@
}

$html += @"
        </div>

        <div class="footer">
            <p>이 메일은 자동으로 생성되었습니다. | 발송 시간: $($today.ToString("HH:mm:ss"))</p>
        </div>
    </div>
</body>
</html>
"@

# 보고서 파일로 저장
$html | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host "✓ 미완료 업무 보고서 생성 완료: $reportFile"
Write-Host "✓ 미완료 업무: $($incompleteTasks.Count)개"
