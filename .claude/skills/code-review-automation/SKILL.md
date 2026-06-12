---
name: code-review-automation
description: |
  자동화된 코드 검토 및 버그 식별 워크플로우. 프로젝트 코드를 체계적으로 검토하고, 
  발견된 문제점을 GitHub 이슈로 등록하며, 각 이슈를 수정하고 댓글을 남깁니다.
  
  **언제 사용**: 새로운 기능 추가 후 품질 점검이 필요하거나, 코드 리뷰를 자동화하고 싶을 때 사용하세요.
  
  **워크플로우**:
  1. 코드 검토 (보안, 성능, 에러 처리)
  2. 이슈 생성 (우선순위별 분류)
  3. 문제점 수정 (각 이슈별 개선)
  4. 수정 확인 (커밋 및 댓글)
  5. 푸시 (GitHub에 반영)

compatibility:
  - Git/GitHub 저장소 필요
  - Bash 또는 PowerShell
  - GitHub CLI (gh) 설치됨
---

# 코드 검토 자동화 스킬

이 스킬을 사용하면 프로젝트의 코드 품질을 체계적으로 개선할 수 있습니다.

## 📋 검토 항목

### 1. 보안 점검
- XSS 취약점 (innerHTML 사용, user input 검증)
- SQL Injection / Command Injection
- 민감한 정보 노출 (API 키, 비밀번호)
- CORS/CSRF 설정

### 2. 성능 점검
- 대량 데이터 처리 시 렉
- 불필요한 재렌더링
- 메모리 누수
- 날짜/시간 계산 최적화

### 3. 에러 처리
- try-catch 누락
- 파일 I/O 에러 처리
- 네트워크 요청 실패 처리
- 사용자 입력 검증

### 4. 데이터 무결성
- null/undefined 체크
- 타입 검증
- 경계값 처리
- 데이터 포맷 검증

### 5. 코드 품질
- 중복 코드
- 과도한 함수 길이
- 네이밍 컨벤션
- 주석의 필요성

## 🔍 문제 분류 체계

### 🔴 높은 우선순위 (P1)
- 데이터 손실 위험
- 보안 취약점
- 앱 크래시 가능성
- 작동 불가능한 기능

### 🟡 중간 우선순위 (P2)
- 성능 저하
- 부분 기능 오류
- 입력 검증 부족
- 에러 처리 미흡

### 🟢 낮은 우선순위 (P3)
- 코드 스타일
- 문서화 부족
- 최적화 가능성
- 구조 개선

## 📝 사용 방법

### 단계 1: 코드 검토 요청

```
내 프로젝트의 manage_ui.html을 검토해주고 
발견된 문제를 이슈로 등록해줘
```

### 단계 2: 자동 생성되는 이슈

스킬이 다음과 같이 이슈를 생성합니다:

```
#1 🐛 [P1] 월말 날짜 계산 버그
   - 현재 코드: setDate(monthEnd.getMonth() + 1)
   - 해결책: setMonth(monthEnd.getMonth() + 1)
   - 영향: 필터링 오류

#2 ⚠️ [P2] JSON 파싱 에러 미처리
   - 현재: JSON.parse() 직접 호출
   - 해결책: try-catch 추가
   - 영향: 앱 크래시 가능
```

### 단계 3: 자동 수정

각 이슈별로 코드를 수정합니다:

```javascript
// 수정 전
function loadTasks() {
    const tasks = localStorage.getItem('tasks');
    return tasks ? JSON.parse(tasks) : [];
}

// 수정 후
function loadTasks() {
    try {
        const tasks = localStorage.getItem('tasks');
        return tasks ? JSON.parse(tasks) : [];
    } catch (error) {
        showNotification('데이터 로드 실패...', 'error');
        return [];
    }
}
```

### 단계 4: 커밋 및 댓글

각 이슈마다 다음을 수행합니다:

1. **커밋 생성**
   ```
   fix: resolve high-priority bugs and improve error handling
   
   - Fix date range calculation
   - Add error handling for JSON parsing
   - ...
   
   Fixes: #1 #3 #4
   ```

2. **이슈 댓글**
   ```
   ✅ **수정 완료!**
   
   ## 변경 사항
   - setDate() → setMonth() 변경
   
   ## 테스트
   - 월중 필터링이 정확히 작동
   
   ## 커밋
   commit: bf4df1c
   ```

### 단계 5: GitHub 푸시

```bash
git push origin main
```

## 🎯 검토 체크리스트

### JavaScript/TypeScript
- JSON 파싱 에러 처리
- null/undefined 체크
- 날짜 형식 검증
- localStorage 용량 제한 처리
- XSS 방지 (innerHTML 대신 textContent)
- 입력값 길이 제한

### PowerShell/Batch
- 파일 존재 확인
- JSON 파싱 에러 처리
- 필수 설정값 검증
- 에러 로깅
- 명확한 에러 메시지

### 전체 프로젝트
- README.md 존재
- 에러 처리 전략 일관성
- 입력 검증 정책
- 로깅 전략
- 문서화

## 📊 검토 결과 예시

```
📋 검토 완료 리포트
═══════════════════════════════════════

🔴 P1 (높음): 3개
  #1 월말 날짜 계산 버그
  #3 JSON 파싱 에러
  #4 localStorage 용량 초과

🟡 P2 (중간): 3개
  #5 날짜 형식 검증
  #6 카테고리 입력 검증
  #7 PowerShell 에러 처리

🟢 P3 (낮음): 2개
  #8 문서화 부족
  #9 성능 최적화

📈 통계
  - 총 이슈: 8개
  - 수정 완료: 7개 ✅
  - 예상 시간: 2-3시간
```

## 💡 팁

### 효율적인 검토
1. **범위 제한**: 한 번에 1-2개 파일만 검토
2. **우선순위 집중**: P1부터 시작
3. **자동화**: 반복되는 패턴 찾기

### 이슈 작성 팁
- **명확한 제목**: [카테고리] 문제 요약
- **상세한 설명**: 현재 코드 + 해결책 + 영향
- **코드 예시**: 문제 있는 코드 블록 포함
- **테스트 방법**: 어떻게 확인할지 명시

### 수정 시 주의사항
1. 한 커밋에 여러 이슈 수정 가능 (Fixes: #1 #3 #4)
2. 수정 후 반드시 테스트
3. 이슈 댓글로 수정 사항 기록
4. 서로 연관된 이슈는 함께 수정

## 📚 참고

- GitHub Issue 작성 가이드
- Conventional Commits
- OWASP Top 10

---

**최종 업데이트**: 2026-06-12
- ✨ 완전한 코드 검토 자동화 워크플로우
- 🔧 실제 적용된 버그 수정 사례
- 📊 우선순위별 이슈 분류 체계
