#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
업무 자동화 시스템 - 핵심 수집 로직
에이전트(Claude) 비탑재 환경에서도 동작하는 독자적 스크립트
"""

import json
import os
from datetime import datetime, timedelta
from pathlib import Path


class TaskCollector:
    """업무 데이터 수집 및 관리"""

    def __init__(self, project_root=None):
        """
        초기화

        Args:
            project_root: 프로젝트 루트 경로 (기본값: 현재 디렉토리)
        """
        self.project_root = Path(project_root or os.getcwd())
        self.tasks_file = self.project_root / "tasks.json"
        self.tasks = self._load_tasks()

    def _load_tasks(self):
        """tasks.json 로드"""
        if not self.tasks_file.exists():
            return []

        try:
            with open(self.tasks_file, "r", encoding="utf-8") as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError) as e:
            print(f"⚠ 작업 로드 실패: {e}")
            return []

    def _save_tasks(self):
        """tasks.json 저장"""
        try:
            with open(self.tasks_file, "w", encoding="utf-8") as f:
                json.dump(self.tasks, f, ensure_ascii=False, indent=2)
            return True
        except IOError as e:
            print(f"✗ 작업 저장 실패: {e}")
            return False

    def collect_today(self):
        """오늘 할 업무 수집"""
        today = datetime.now().strftime("%Y-%m-%d")
        today_tasks = [t for t in self.tasks if t.get("dueDate") == today]
        return today_tasks

    def collect_incomplete(self):
        """미완료 업무 수집"""
        incomplete = [t for t in self.tasks if t.get("status") != "COMPLETED"]
        return incomplete

    def collect_by_month(self, year, month):
        """특정 월의 업무 수집

        Args:
            year: 년도 (2026 등)
            month: 월 (1-12)
        """
        month_str = f"{year}-{month:02d}"
        month_tasks = [
            t for t in self.tasks
            if t.get("dueDate", "").startswith(month_str)
        ]
        return month_tasks

    def collect_by_category(self, category):
        """카테고리별 업무 수집"""
        return [t for t in self.tasks if t.get("category") == category]

    def get_categories(self):
        """모든 대분류 목록"""
        return list(set(t.get("category") for t in self.tasks if t.get("category")))

    def calculate_progress(self, category=None, month=None):
        """진척도 계산

        Args:
            category: 대분류 (생략시 전체)
            month: 월 (2026-06 형식, 생략시 전체)
        """
        filtered = self.tasks

        if category:
            filtered = [t for t in filtered if t.get("category") == category]

        if month:
            filtered = [t for t in filtered if t.get("dueDate", "").startswith(month)]

        if not filtered:
            return {"total": 0, "completed": 0, "percentage": 0}

        total = len(filtered)
        completed = sum(1 for t in filtered if t.get("status") == "COMPLETED")

        return {
            "total": total,
            "completed": completed,
            "percentage": int((completed / total) * 100) if total > 0 else 0,
        }

    def generate_report(self, output_file=None):
        """일일 보고서 생성

        Args:
            output_file: 출력 파일 경로 (기본값: daily_report.json)
        """
        if output_file is None:
            output_file = self.project_root / "daily_report.json"

        today = datetime.now().strftime("%Y-%m-%d")
        today_tasks = self.collect_today()
        incomplete_today = [t for t in today_tasks if t.get("status") != "COMPLETED"]

        report = {
            "date": today,
            "generated_at": datetime.now().isoformat(),
            "summary": {
                "total_today": len(today_tasks),
                "incomplete_today": len(incomplete_today),
                "total_incomplete": len(self.collect_incomplete()),
            },
            "today_tasks": today_tasks,
            "incomplete_tasks": incomplete_today,
            "categories": {
                cat: self.calculate_progress(category=cat) for cat in self.get_categories()
            },
        }

        try:
            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(report, f, ensure_ascii=False, indent=2)
            return report
        except IOError as e:
            print(f"✗ 보고서 생성 실패: {e}")
            return None

    def add_task(self, category, subcategory, title, priority, due_date, recurring_type=None):
        """새 업무 추가"""
        task = {
            "id": int(datetime.now().timestamp() * 1000),
            "category": category,
            "subcategory": subcategory,
            "title": title or "(상세내용 없음)",
            "priority": priority,
            "dueDate": due_date,
            "status": "PENDING",
            "isRecurring": recurring_type is not None and recurring_type != "none",
            "recurringType": recurring_type,
        }

        self.tasks.append(task)
        self._save_tasks()
        return task

    def update_task_status(self, task_id, status):
        """업무 상태 업데이트"""
        for task in self.tasks:
            if task.get("id") == task_id:
                task["status"] = status
                self._save_tasks()
                return True
        return False


def main():
    """테스트 및 데모"""
    collector = TaskCollector()

    print("📋 업무 자동화 시스템 - 수집 로직\n")

    # 통계
    print(f"✓ 총 업무: {len(collector.tasks)}개")
    print(f"✓ 미완료: {len(collector.collect_incomplete())}개")
    print(f"✓ 카테고리: {len(collector.get_categories())}개")

    # 오늘 업무
    today_tasks = collector.collect_today()
    print(f"\n📌 오늘 업무: {len(today_tasks)}개")
    for task in today_tasks[:3]:  # 처음 3개만 표시
        status = "✓" if task.get("status") == "COMPLETED" else "○"
        print(f"  {status} {task.get('category')} > {task.get('subcategory')}")

    # 보고서 생성
    report = collector.generate_report()
    if report:
        print(f"\n📊 보고서 생성: daily_report.json")
        print(f"  - 오늘 완료: {report['summary']['incomplete_today']}/{report['summary']['total_today']}")


if __name__ == "__main__":
    main()
