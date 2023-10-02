import boto3
import json
from boto3.dynamodb.conditions import Key

dynamodb_resource = boto3.resource("dynamodb")
table = dynamodb_resource.Table("notes-30144844")


def get_lambda_handler_30144844(event, context):
    email = event['queryStringParameters']['email']
    accessToken = event['headers']['access_token']
    if not accessToken:
        return {
            'statusCode': 401,
            'body': json.dumps({'message': 'Unauthorized'})
        }
    try:
        response = table.query(KeyConditionExpression=Key("email").eq(email))
        return {
            "statusCode": 200,
            "body": json.dumps(response["Items"])
        }
    except Exception as exp:
        print(exp)
        return {
            "statusCode": 500,
            "body": str(exp)
        }
