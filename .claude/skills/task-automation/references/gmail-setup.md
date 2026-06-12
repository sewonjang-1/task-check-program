# Gmail 앱 비밀번호 설정 가이드

## 2단계 인증 활성화

1. Google 계정 이동 (https://myaccount.google.com)
2. 왼쪽 메뉴에서 "보안" 클릭
3. "2단계 인증" 섹션으로 이동
4. "2단계 인증 설정" 클릭
5. 지시에 따라 인증 방법 설정 (휴대폰 번호 등)

## 앱 비밀번호 생성

1. Google 계정 보안 페이지에서
2. "앱 비밀번호" 섹션 찾기
3. 앱: Gmail 선택
4. 기기: 컴퓨터 선택
5. "생성" 클릭
6. 16자 비밀번호 복사

## email_config.json에 입력

```json
{
  "smtp_server": "smtp.gmail.com",
  "smtp_port": 587,
  "sender_email": "your-email@gmail.com",
  "sender_password": "여기에 16자 비밀번호 붙여넣기",
  "recipient_email": "recipient@example.com"
}
```

**주의**: 실제 Gmail 비밀번호가 아니라 앱 비밀번호를 사용합니다.
