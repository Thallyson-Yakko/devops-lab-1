from flask import Flask, jsonify
import boto3, os

app = Flask(__name__)

s3 = boto3.client("s3", endpoint_url=os.getenv("AWS_ENDPOINT_URL", "http://localhost:4566"))
SQS = boto3.client("sqs", endpoint_url=os.getenv("AWS_ENDPOINT_URL", "http://localhost:4566"))
QUEUE_URL = os.getenv("SQS_QUEUE_URL")
BUCKET = os.getenv("S3_BUCKET")

@app.route("/upload/<filename>", methods=["POST"])
def upload(filename):
    s3.put_object(Bucket=BUCKET, Key=filename, Body=b"conteudo de exemplo")
    SQS.send_message(QueueUrl=QUEUE_URL, MessageBody=f"uploaded:{filename}")
    return jsonify({"status": "ok", "file": filename})

@app.route("/files")
def list_files():
    resp = s3.list_objects_v2(Bucket=BUCKET)
    files = [obj["Key"] for obj in resp.get("Contents", [])]
    return jsonify({"files": files})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
