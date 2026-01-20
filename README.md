# Demo App Monitoring

Flask 앱 + Fluent Bit + CloudWatch + AWS Managed Grafana 모니터링 데모

## 구성요소

- **Flask App**: 로그/메트릭 생성 샘플 앱
- **Fluent Bit**: 로그 수집 → CloudWatch 전송
- **Terraform**: AWS Managed Grafana 프로비저닝
- **Grafana Dashboard**: CloudWatch Logs 시각화

## 실행 방법

### 1. 환경변수 설정(.env 생성할것)

```bash
AWS_ACCESS_KEY_ID=<액세스키>
AWS_SECRET_ACCESS_KEY=<시크릿키>
# .env 파일에 AWS 키 입력
```

### 2. 앱 실행
```bash
docker-compose up --build
```

### 3. 테스트
```bash
curl http://localhost:5000/        # 일반 요청
curl http://localhost:5000/error   # 에러 생성
curl http://localhost:5000/metrics # 메트릭 확인
```

### 4. Grafana 설정 (최초 1회)
```bash
cd terraform
terraform init
terraform apply
```

### 5. 대시보드 임포트

- `dashboard.json`파일의 logGroup 에 cloudwatch-로그-Log Management의 본인 ARN 입력
- Grafana 접속 → Dashboards → Import
- `grafana/dashboard.json` 업로드


## 엔드포인트

| 경로 | 설명 |
|------|------|
| `/` | 요청 카운트 증가 + INFO 로그 |
| `/error` | 에러 카운트 증가 + ERROR 로그 |
| `/metrics` | 현재 메트릭 JSON 반환 |

## CloudWatch 로그 그룹

- `/demo-app/logs` - 앱 로그
- `/demo-app/metrics` - 메트릭 로그
