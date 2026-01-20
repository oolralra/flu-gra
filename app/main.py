"""간단한 Flask 앱 - 로그와 메트릭 생성"""
import logging
import random
import time
import json
from datetime import datetime
from flask import Flask, jsonify

app = Flask(__name__)

# JSON 형식 로그 설정
class JsonFormatter(logging.Formatter):
    def format(self, record):
        return json.dumps({
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name
        })

handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
logging.root.handlers = [handler]
logging.root.setLevel(logging.INFO)
logger = logging.getLogger("demo-app")

# 메트릭 저장용
metrics = {"requests": 0, "errors": 0}

@app.route("/")
def home():
    metrics["requests"] += 1
    logger.info(f"Request received - total: {metrics['requests']}")
    return jsonify({"status": "ok", "requests": metrics["requests"]})

@app.route("/error")
def error():
    metrics["errors"] += 1
    logger.error(f"Error triggered - total errors: {metrics['errors']}")
    return jsonify({"status": "error"}), 500

@app.route("/metrics")
def get_metrics():
    """Fluent Bit이 수집할 메트릭 엔드포인트"""
    return jsonify({
        "timestamp": datetime.utcnow().isoformat(),
        "app": "demo-app",
        "requests_total": metrics["requests"],
        "errors_total": metrics["errors"],
        "uptime_seconds": time.time()
    })

if __name__ == "__main__":
    logger.info("Demo app starting...")
    app.run(host="0.0.0.0", port=5000)
