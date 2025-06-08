import boto3
import json
import os

# Initialize AWS S3 client
s3 = boto3.client("s3")

# Define S3 bucket name from environment variable
BUCKET_NAME = os.getenv("LITESTREAM_BUCKET", "vaultwarden-litestream-bucket")

def lambda_handler(event, context):
    try:
        # Example: Read object from S3
        response = s3.get_object(Bucket=BUCKET_NAME, Key="db.sqlite3")
        data = response["Body"].read().decode("utf-8")

        # Example: Write object to S3
        s3.put_object(Bucket=BUCKET_NAME, Key="backup-db.sqlite3", Body=data)

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Backup successful", "bucket": BUCKET_NAME})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
