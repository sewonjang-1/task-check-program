# 커스터마이제이션 가이드

## 대분류 변경하기

manage_ui.html을 텍스트 에디터로 열고:

```javascript
// 약 800줄 근처에서 찾기
function getCategoryList() {
    const tasks = loadTasks();
    const categories = new Set();
    tasks.forEach(task => {
        categories.add(task.category);
    });
    return Array.from(categories).sort();
}
```

## 이메일 제목/내용 변경

incomplete_report_generator.ps1을 수정:

```powershell
$mailMessage.Subject = "custom subject here"
```

## 자동 실행 시간 변경

setup_incomplete_scheduler.ps1에서:

```powershell
-At "17:00"   # 여기를 변경 (24시간 형식)
```

## 로컬 저장소 위치 변경

manage_ui.html에서:

```javascript
localStorage.setItem('tasks', JSON.stringify(tasks));
// 대신 IndexedDB나 다른 저장소 사용 가능
```
