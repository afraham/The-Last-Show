import boto3
import json

dynamodb_resource = boto3.resource("dynamodb")
table = dynamodb_resource.Table("notes-30144844")


def save_lambda_handler_30144844(event, context):
    body = json.loads(event["body"])
    accessToken = event['headers']['access_token']
    if not accessToken:
        return {
            'statusCode': 401,
            'body': json.dumps({'message': 'Unauthorized'})
        }
    try:
        table.put_item(Item=body)
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Successfully added Note!"
            })
        }
    except Exception as e:
        print(f"Exception: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": str(e)
            })
        }
