#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
from datetime import datetime, timedelta
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
TASKS_FILE = SCRIPT_DIR / "tasks.json"
REPORT_FILE = SCRIPT_DIR / "daily_report.html"

PRIORITY_ORDER = {"HIGH": 1, "MEDIUM": 2, "LOW": 3}

def load_tasks():
    """tasks.json 파일 읽기"""
    if not TASKS_FILE.exists():
        return {"tasks": []}

    with open(TASKS_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def get_tasks_by_date(tasks, target_date):
    """특정 날짜의 업무 필터링"""
    return [t for t in tasks if t['dueDate'] == target_date.strftime('%Y-%m-%d')]

def get_tasks_by_date_range(tasks, start_date, end_date):
    """날짜 범위의 업무 필터링"""
    result = []
    current = start_date
    while current <= end_date:
        date_str = current.strftime('%Y-%m-%d')
        result.extend([t for t in tasks if t['dueDate'] == date_str])
        current += timedelta(days=1)
    return result

def sort_tasks_by_priority(tasks):
    """우선순위별 정렬"""
    return sorted(tasks, key=lambda x: PRIORITY_ORDER.get(x['priority'], 4))

def generate_html_report(today_tasks, tomorrow_tasks, this_week_tasks, next_week_tasks, all_tasks):
    """HTML 보고서 생성"""

    # 통계 계산
    total_tasks = len(all_tasks)
    completed_tasks = len([t for t in all_tasks if t['status'] == 'COMPLETED'])
    pending_tasks = total_tasks - completed_tasks
    completion_rate = (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0

    # 우선순위별 정렬
    today_tasks_sorted = sort_tasks_by_priority(today_tasks)

    # 오늘 업무 HTML
    today_html = ""
    if today_tasks_sorted:
        for task in today_tasks_sorted:
            priority_color = {"HIGH": "#ff6b6b", "MEDIUM": "#ffa94d", "LOW": "#69db7c"}
            priority_icon = {"HIGH": "🔴", "MEDIUM": "🟠", "LOW": "🟢"}
            status_icon = "✅" if task['status'] == 'COMPLETED' else "⭕"

            today_html += f"""
            <div class="task-item" style="border-left: 4px solid {priority_color.get(task['priority'], '#999')}">
                <div class="task-header">
                    <span class="status-icon">{status_icon}</span>
                    <span class="task-title">{task['title']}</span>
                    <span class="priority-badge">{priority_icon.get(task['priority'])} {task['priority']}</span>
                </div>
                <div class="task-description">{task['description']}</div>
            </div>
            """
    else:
        today_html = '<p style="color: #999; padding: 20px;">오늘 할당된 업무가 없습니다.</p>'

    # 내일 업무 HTML
    tomorrow_html = ""
    if tomorrow_tasks:
        tomorrow_html = f"<p>내일 예정된 업무: <strong>{len(tomorrow_tasks)}</strong>건</p>"

    # 이번주 업무 HTML
    this_week_html = ""
    if this_week_tasks:
        this_week_html = f"<p>이번주 예정된 업무: <strong>{len(this_week_tasks)}</strong>건</p>"

    # 다음주 업무 HTML
    next_week_html = ""
    if next_week_tasks:
        next_week_html = f"<p>다음주 예정된 업무: <strong>{len(next_week_tasks)}</strong>건</p>"

    # 최종 HTML
    html_content = f"""<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일일 업무 보고서</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
            background: #f5f5f5;
            padding: 20px;
            color: #333;
        }}

        .container {{
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            overflow: hidden;
        }}

        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }}

        .header h1 {{
            font-size: 24px;
            margin-bottom: 10px;
        }}

        .header p {{
            font-size: 14px;
            opacity: 0.9;
        }}

        .section {{
            padding: 25px 30px;
            border-bottom: 1px solid #eee;
        }}

        .section:last-child {{
            border-bottom: none;
        }}

        .section-title {{
            font-size: 18px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }}

        .task-item {{
            background: #f9f9f9;
            padding: 12px 15px;
            margin-bottom: 10px;
            border-radius: 6px;
            border-left: 4px solid #667eea;
        }}

        .task-header {{
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 5px;
        }}

        .status-icon {{
            font-size: 16px;
        }}

        .task-title {{
            font-weight: 500;
            flex: 1;
        }}

        .priority-badge {{
            background: #f0f0f0;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 12px;
            white-space: nowrap;
        }}

        .task-description {{
            font-size: 13px;
            color: #666;
            margin-left: 26px;
        }}

        .stats {{
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 15px;
        }}

        .stat-box {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            border-radius: 6px;
            text-align: center;
        }}

        .stat-number {{
            font-size: 24px;
            font-weight: bold;
        }}

        .stat-label {{
            font-size: 12px;
            opacity: 0.9;
            margin-top: 5px;
        }}

        .schedule-grid {{
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }}

        .schedule-item {{
            background: #f9f9f9;
            padding: 15px;
            border-radius: 6px;
            border-left: 3px solid #667eea;
        }}

        .schedule-item p {{
            margin: 5px 0;
            font-size: 14px;
        }}

        .footer {{
            background: #f5f5f5;
            padding: 15px 30px;
            text-align: center;
            font-size: 12px;
            color: #999;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 일일 업무 보고서</h1>
            <p>{datetime.now().strftime('%Y년 %m월 %d일 (%A)')}</p>
        </div>

        <div class="section">
            <div class="section-title">📊 요약 통계</div>
            <div class="stats">
                <div class="stat-box">
                    <div class="stat-number">{total_tasks}</div>
                    <div class="stat-label">전체 업무</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">{completed_tasks}</div>
                    <div class="stat-label">완료</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">{pending_tasks}</div>
                    <div class="stat-label">진행중</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">{completion_rate:.0f}%</div>
                    <div class="stat-label">완료율</div>
                </div>
            </div>
        </div>

        <div class="section">
            <div class="section-title">📌 오늘의 업무</div>
            {today_html}
        </div>

        <div class="section">
            <div class="section-title">📅 기간별 예정</div>
            <div class="schedule-grid">
                <div class="schedule-item">
                    <p><strong>내일 (내일)</strong></p>
                    {tomorrow_html if tomorrow_html else '<p style="color: #999;">예정된 업무 없음</p>'}
                </div>
                <div class="schedule-item">
                    <p><strong>이번주</strong></p>
                    {this_week_html if this_week_html else '<p style="color: #999;">예정된 업무 없음</p>'}
                </div>
                <div class="schedule-item">
                    <p><strong>다음주</strong></p>
                    {next_week_html if next_week_html else '<p style="color: #999;">예정된 업무 없음</p>'}
                </div>
                <div class="schedule-item">
                    <p><strong>우선순위</strong></p>
                    <p>HIGH: {len([t for t in all_tasks if t['priority'] == 'HIGH'])}</p>
                    <p>MEDIUM: {len([t for t in all_tasks if t['priority'] == 'MEDIUM'])}</p>
                    <p>LOW: {len([t for t in all_tasks if t['priority'] == 'LOW'])}</p>
                </div>
            </div>
        </div>

        <div class="footer">
            <p>이 보고서는 자동으로 생성되었습니다. | 생성 시간: {datetime.now().strftime('%H:%M:%S')}</p>
        </div>
    </div>
</body>
</html>"""

    return html_content

def main():
    """메인 함수"""
    # 날짜 설정
    today = datetime.now()
    tomorrow = today + timedelta(days=1)
    week_start = today
    week_end = today + timedelta(days=6)
    next_week_start = today + timedelta(days=7)
    next_week_end = today + timedelta(days=13)

    # 업무 로드
    data = load_tasks()
    all_tasks = data.get('tasks', [])

    # 날짜별 업무 필터링
    today_tasks = get_tasks_by_date(all_tasks, today)
    tomorrow_tasks = get_tasks_by_date(all_tasks, tomorrow)
    this_week_tasks = get_tasks_by_date_range(all_tasks, week_start, week_end)
    next_week_tasks = get_tasks_by_date_range(all_tasks, next_week_start, next_week_end)

    # HTML 생성
    html = generate_html_report(today_tasks, tomorrow_tasks, this_week_tasks, next_week_tasks, all_tasks)

    # 파일 저장
    with open(REPORT_FILE, 'w', encoding='utf-8') as f:
        f.write(html)

    print(f"✅ 보고서가 생성되었습니다: {REPORT_FILE}")
    return html

if __name__ == "__main__":
    main()
