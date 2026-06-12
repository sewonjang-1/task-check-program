# 📧 미완료 업무 자동 메일 발송 설정 가이드

매일 오후 5시에 미완료 업무를 자동으로 메일로 받도록 설정합니다.

## 🚀 빠른 설정 (자동)

### **1단계: PowerShell 관리자 권한으로 실행**

```powershell
# PowerShell을 관리자 권한으로 실행
# (시작 → PowerShell → 마우스 오른쪽 클릭 → 관리자 권한으로 실행)

cd "C:\Users\Admin\Desktop\2일차 과제-1"
.\setup_incomplete_scheduler.ps1
```

**완료!** 작업이 자동으로 등록됩니다.

---

## 🧪 테스트하기

미완료 업무 메일이 제대로 발송되는지 테스트합니다.

### **방법 1: 배치 파일 실행 (쉬움)**

```
C:\Users\Admin\Desktop\2일차 과제-1\test_incomplete_scheduler.bat
```

더블클릭하여 실행하면 즉시 메일 발송을 테스트할 수 있습니다.

### **방법 2: PowerShell 실행**

```powershell
cd "C:\Users\Admin\Desktop\2일차 과제-1"

# 보고서 생성
.\incomplete_report_generator.ps1

# 메일 발송
.\incomplete_mailer.ps1
```

---

## 📋 설정 확인

### **Windows Task Scheduler 확인**

1. **작업 스케줄러 열기**
   - `Windows + R` → `taskschd.msc` 입력

2. **작업 확인**
   - 왼쪽 폴더에서: 업무자동화 → 미완료 업무 메일 발송 (오후 5시)

3. **트리거 확인**
   - 오른쪽 클릭 → 속성
   - **트리거 탭**: 매일 17:00:00 (오후 5시)

### **로그 확인**

```
C:\Users\Admin\Desktop\2일차 과제-1\logs\incomplete_mail_log.txt
```

메일 발송 기록을 확인할 수 있습니다.

---

## 🛠️ 수동 설정 (Task Scheduler)

자동 설정이 안 되면 수동으로 설정하세요.

### **1. 작업 스케줄러 열기**

```
Windows + R → taskschd.msc
```

### **2. 작업 만들기**

1. 오른쪽 사이드바 → **"작업 만들기"**

2. **기본 탭**
   - 이름: `미완료 업무 메일 발송 (오후 5시)`
   - 설명: `매일 오후 5시에 미완료 업무를 메일로 발송`
   - ☑️ 가장 높은 수준의 권한으로 실행

3. **트리거 탭**
   - "새로 만들기" 클릭
   - 시작: **매일**
   - 시작 시간: **17:00:00**
   - 반복 간격: **매일**
   - "확인" 클릭

4. **작업 탭**
   - "새로 만들기" 클릭
   - 프로그램: 
     ```
     C:\Users\Admin\Desktop\2일차 과제-1\incomplete_scheduler.bat
     ```
   - 시작 위치:
     ```
     C:\Users\Admin\Desktop\2일차 과제-1
     ```
   - "확인" 클릭

5. **확인** → **마침**

---

## 📧 메일 내용

매일 오후 5시에 다음과 같은 메일이 발송됩니다:

```
제목: ⚠️ 오늘 미완료 업무 알림 - 2026년 06월 12일

본문:
⚠️ 오늘 미완료 업무 알림
2026년 06월 12일 (금요일)

📌 미완료 업무: 3개
빨리 완료하고 퇴근하세요! 💪

🏷️ 부가세 신고
  수출 - 선적일 확인하기 [높음]
  수출/내수 - 영세율 서류 요청하기 [높음]

🏷️ 회계
  월급 - 급여 지급 [높음]
```

---

## ⚙️ 파일 구조

```
C:\Users\Admin\Desktop\2일차 과제-1\
├── setup_incomplete_scheduler.ps1       ← 자동 설정 스크립트
├── test_incomplete_scheduler.bat        ← 테스트 배치 파일
├── incomplete_report_generator.ps1      ← 보고서 생성
├── incomplete_mailer.ps1                ← 메일 발송
├── incomplete_scheduler.bat             ← 자동 실행 배치
├── logs/
│   └── incomplete_mail_log.txt          ← 발송 로그
└── incomplete_report.html               ← 생성된 보고서
```

---

## 🔧 문제 해결

### **메일이 안 나가요**

1. **email_config.json 확인**
   ```json
   {
     "smtp_server": "smtp.gmail.com",
     "smtp_port": 587,
     "sender_email": "your-email@gmail.com",
     "sender_password": "your-app-password",
     "recipient_email": "recipient@example.com"
   }
   ```

2. **로그 확인**
   ```
   logs/incomplete_mail_log.txt
   ```

3. **테스트 실행**
   ```
   test_incomplete_scheduler.bat
   ```

### **작업이 자동 실행 안 됨**

1. Task Scheduler가 실행 중인지 확인
2. 컴퓨터가 오후 5시에 켜져 있는지 확인
3. Task Scheduler에서 작업 상태 확인
4. 마지막 실행 결과 확인

### **권한 오류**

PowerShell을 **관리자 권한**으로 실행하세요.

---

## 💡 팁

### **로그 확인하기**

```powershell
# 최근 발송 기록
Get-Content "logs\incomplete_mail_log.txt" -Tail 10
```

### **작업 수동 실행하기**

```powershell
# Task Scheduler에서 작업 선택 → "실행" 버튼
# 또는 PowerShell에서
Start-ScheduledTask -TaskPath "\업무자동화\" -TaskName "미완료 업무 메일 발송 (오후 5시)"
```

### **작업 비활성화하기**

```powershell
Disable-ScheduledTask -TaskPath "\업무자동화\" -TaskName "미완료 업무 메일 발송 (오후 5시)"
```

---

## ✅ 완료!

이제 매일 오후 5시에 미완료 업무를 자동으로 메일로 받을 수 있습니다!

🎉 **설정이 완료되었습니다!**
