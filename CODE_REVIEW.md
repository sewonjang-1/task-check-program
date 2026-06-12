# 📋 코드 검토 보고서 (Code Review)

**검토 일시:** 2026-06-12  
**검토자:** Claude Haiku 4.5  
**상태:** REVIEW_NEEDED  

---

## 📊 종합 평가

| 항목 | 결과 | 설명 |
|------|------|------|
| 총 이슈 수 | 19개 | P1: 4, P2: 7, P3: 8 |
| 현재 등급 | A+ (92%) | RUBRIC.md 기준 |
| 목표 등급 | S (95%+) | P1 이슈 해결 시 |
| 배포 권장 | ❌ NO | P1 이슈 먼저 해결 필요 |
| 예상 수정시간 | 6-8시간 | P1: 2-3h, P2: 4-5h |

---

## 🔴 P1 (Critical) - 4개 이슈

P1 이슈는 보안 취약점, 버그, 또는 기능 오류입니다. **즉시 해결 필수.**

### P1-001: XSS Vulnerability in Event Handlers
**파일:** `manage_ui.html:1081`  
**위험도:** HIGH  
**카테고리:** SECURITY  

**문제:**
```javascript
// 현재 (취약함)
onchange="toggleSubcategoryComplete('${category}', '${subcategory}')"
```
카테고리명에 `'); alert('xss'); ('` 같은 코드를 포함하면 JavaScript 실행 가능.

**해결책:**
```javascript
// 개선 (안전함)
<input type="checkbox" 
  class="subcategory-checkbox"
  data-category="${escapeHtml(category)}"
  data-subcategory="${escapeHtml(subcategory)}">

// 이벤트 리스너로 처리
document.addEventListener('change', (e) => {
  if (e.target.classList.contains('subcategory-checkbox')) {
    const { category, subcategory } = e.target.dataset;
    toggleSubcategoryComplete(category, subcategory);
  }
});
```

**영향도:** 임의 JavaScript 실행, 데이터 탈취, 악성코드 주입

---

### P1-002: DOM-based XSS in Inline Event Handlers
**파일:** `manage_ui.html:1099-1101`  
**위험도:** MEDIUM  
**카테고리:** SECURITY  

**문제:**
```javascript
// 현재 (위험함)
<button onclick="editTask(${task.id})">수정</button>
<button onclick="deleteTask(${task.id})">삭제</button>
```

**해결책:**
```javascript
// 개선
<button class="edit-btn" data-task-id="${task.id}">수정</button>

// 이벤트 위임
document.addEventListener('click', (e) => {
  if (e.target.classList.contains('edit-btn')) {
    editTask(parseInt(e.target.dataset.taskId, 10));
  }
});
```

**영향도:** 다중 취약점 패턴으로 인한 보안 심사 실패

---

### P1-003: JSON Schema Inconsistency
**파일:** `tasks.json:2,21`  
**위험도:** HIGH  
**카테고리:** BUG  

**문제:**
```json
// Task 1: recurringType 있음
{
  "id": 1,
  "category": "업무",
  "recurringType": "daily",
  "isRecurring": true
}

// Task 2: recurringType 없음 (버그!)
{
  "id": 2,
  "category": "업무",
  // 이 필드가 없으면 undefined 오류 발생
}
```

관련 코드에서 `task.recurringType` 접근 시 undefined 오류 가능.

**해결책:**

a) tasks.json 수정: 모든 task에 필드 추가
```json
{
  "id": 2,
  "category": "업무",
  "recurringType": "none",
  "isRecurring": false
}
```

b) manage_ui.html에서 정규화 (더 견고):
```javascript
function normalizeTasks(tasks) {
  return tasks.map(task => ({
    ...task,
    isRecurring: task.isRecurring ?? false,
    recurringType: task.recurringType ?? 'none'
  }));
}

// loadTasks() 에서 호출
let tasks = normalizeTasks(parsedTasks);
```

**영향도:** 런타임 오류, 예기치 않은 동작, 데이터 손상

---

### P1-004: Non-functional ActiveXObject Code
**파일:** `manage_ui.html:1436`  
**위험도:** HIGH  
**카테고리:** BUG  

**문제:**
```javascript
// 현재 (완전히 작동 안 함)
try {
  let shell = new ActiveXObject("WScript.Shell");
  shell.Run("cmd /c incomplete_scheduler.bat");
} catch (e) {
  // Chrome, Firefox, 모던 Edge에서는 여기로 와서 그냥 넘어감
  console.error(e);
}
```

- ActiveXObject는 IE/Edge Legacy 에서만 작동
- 모던 Chrome, Firefox에서는 실패
- 실패해도 조용히 넘어감 (silent failure)

**해결책:**

방법 1: 백엔드 API 호출 (권장)
```javascript
function sendIncompleteMailNow() {
  fetch('/api/send-incomplete-report', { method: 'POST' })
    .then(r => r.json())
    .then(data => {
      showAlert(`이메일 발송 완료: ${data.timestamp}`);
    })
    .catch(() => {
      showAlert('⚠️ API 서버 오류. 수동 실행: .\\scripts\\run-incomplete.bat');
    });
}
```

방법 2: 사용자 가이드 제공 (단기 해결책)
```javascript
function sendIncompleteMailNow() {
  showAlert(`
    자동 발송은 Windows Task Scheduler에 설정되어 있습니다.
    수동 실행하려면:
    1. 탐색기에서: ${batFilePath} 더블클릭
    2. 또는 PowerShell: .\\scripts\\run-incomplete.bat
  `);
}
```

**영향도:** 기능 완전히 작동 안 함, 사용자가 모름

---

## 🟡 P2 (Major) - 7개 이슈

P2 이슈는 데이터 손상, 성능 저하, 또는 오류 처리 문제입니다. **배포 전 해결 권장.**

### P2-001: Edit Mode Not Properly Cleared
**파일:** `manage_ui.html:824`  
**위험도:** MEDIUM  
**카테고리:** BUG  

**문제:**
사용자가 업무 수정 중 다른 탭으로 이동하면 `editingTaskId`가 유지됨. 다음 "업무 추가" 클릭 시 새로운 업무가 아닌 기존 업무를 덮어씀.

**해결책:**
```javascript
function switchTab(tabName) {
  // 탭 전환 시 편집 상태 초기화
  editingTaskId = null;
  clearForm();
  
  // 나머지 탭 전환 로직...
}

// 또는 경고 표시
function switchTab(tabName) {
  if (editingTaskId !== null) {
    if (!confirm('수정 중인 업무가 있습니다. 취소하시겠습니까?')) {
      return;
    }
  }
  editingTaskId = null;
  clearForm();
  // ...
}
```

**영향도:** 조용한 데이터 손상 (사용자 모름)

---

### P2-002: Insufficient Error Messages in Validation
**파일:** `manage_ui.html:706-722`  
**위험도:** MEDIUM  
**카테고리:** CODE_QUALITY  

**문제:**
```javascript
// 현재 (정보 부족)
throw new Error('길이는 1~30자여야 합니다');
// 사용자는 어느 필드인지 모름
```

**해결책:**
```javascript
function validateInputLength(value, minLen, maxLen, fieldName) {
  if (value.length < minLen || value.length > maxLen) {
    throw new Error(`${fieldName}: ${minLen}~${maxLen}자여야 합니다`);
  }
  return value;
}

// 호출 시
try {
  category = validateInputLength(category, 1, 30, '대분류');
  subcategory = validateInputLength(subcategory, 1, 30, '소분류');
} catch (e) {
  showAlert(`❌ ${e.message}`);
}
```

**영향도:** 사용자 경험 저하, 디버깅 어려움

---

### P2-003: Memory Inefficiency with Large Tasks
**파일:** `manage_ui.html:1012-1038`  
**위험도:** MEDIUM  
**카테고리:** PERFORMANCE  

**문제:**
```javascript
// 현재 (비효율적)
function renderTasks() {
  taskList.innerHTML = ''; // 전체 DOM 재구성
  tasks.forEach(task => {
    taskList.innerHTML += `<div>...</div>`; // 매번 문자열 연결
  });
}
// 1000개 항목 = 1000번 DOM 업데이트, 매우 느림
```

**해결책:**

단기:
```javascript
function renderTasks() {
  const html = tasks.map(task => `<div>${task.title}</div>`).join('');
  taskList.innerHTML = html; // 1회만 업데이트
}
```

장기 (RUBRIC.md Phase 2):
```javascript
function renderTasksWithPagination(pageSize = 50) {
  const start = currentPage * pageSize;
  const end = start + pageSize;
  const pageTasks = tasks.slice(start, end);
  // 필요한 것만 렌더링
}
```

**영향도:** 100+ 항목 시 UI 반응성 저하

---

### P2-004 ~ P2-007
(상세는 코드 리뷰 결과 JSON 참조)

---

## 🟢 P3 (Minor) - 8개 이슈

P3 이슈는 코드 품질, 문서화, 또는 미래 호환성입니다. **여유 있을 때 해결.**

### P3-001: Dead Code
**파일:** `manage_ui.html:1468-1471`  
**제안:** 라인 제거 (존재하지 않는 요소 참조)

### P3-002: IndexedDB Migration Path Missing
**파일:** `RUBRIC.md:141`  
**제안:** SOUL.md Phase 2에 마이그레이션 전략 문서화

### P3-003 ~ P3-007
(구체적 제안은 코드 리뷰 결과 참조)

---

## ✅ 개선 계획

### Phase 1: P1 이슈 해결 (필수)
- [ ] P1-001: 모든 inline event handlers 제거 → data attributes + 이벤트 위임
- [ ] P1-002: 추가 inline handlers 정리
- [ ] P1-003: tasks.json 정규화 또는 loadTasks() 정규화
- [ ] P1-004: ActiveXObject 제거 또는 백엔드 API 추가
- [ ] 커밋: `fix: address critical security and bug issues (P1)`

**예상 시간:** 2-3시간

### Phase 2: P2 이슈 해결 (권장)
- [ ] 탭 전환 시 편집 상태 초기화
- [ ] 에러 메시지에 필드명 포함
- [ ] 렌더링 성능 최적화 (1000+ 항목 지원)
- [ ] 배치 파일 오류 처리 개선
- [ ] 커밋: `refactor: improve error handling and performance (P2)`

**예상 시간:** 4-5시간

### Phase 3: P3 이슈 해결 (선택)
- [ ] 데드 코드 제거
- [ ] 문서 업데이트
- [ ] 마이그레이션 경로 정의
- [ ] 커밋: `chore: code cleanup and documentation (P3)`

**예상 시간:** 1-2시간

---

## 📈 품질 영향

| 단계 | 현재 | 해결 후 | 달성 항목 |
|------|------|--------|---------|
| 현재 | A+ (92%) | A+ (92%) | - |
| P1 해결 | - | A+ (93%) | 보안/버그 제거 |
| P1+P2 해결 | - | S (95%+) | 완전 생산용 |
| P1+P2+P3 해결 | - | S+ (98%+) | 최고 품질 |

---

## 🎯 다음 단계

1. **즉시:** P1-001, P1-003 해결 (보안 & 버그)
2. **오늘 중:** P1-002, P1-004 해결
3. **내일:** P2 이슈 패치
4. **검증:** 모든 테스트 통과 후 배포

---

## 📝 참고사항

- 이 검토는 자동화된 코드 분석 + 수동 검토의 결과
- 모든 제안은 프로젝트 아키텍처 철학(SOUL.md) 및 협업 규칙(CLAUDE.md) 준수
- P1 이슈 해결이 배포 전 필수 요건
- RUBRIC.md와 연계하여 S 등급 달성 가능

---

## 📚 관련 문서
- [품질 루브릭 → RUBRIC.md](RUBRIC.md)
- [프로젝트 철학 → SOUL.md](SOUL.md)
- [협업 규칙 → CLAUDE.md](CLAUDE.md)
