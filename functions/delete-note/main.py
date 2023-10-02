import boto3
import json

dynamodb_resource = boto3.resource("dynamodb")
table = dynamodb_resource.Table("notes-30144844")


def delete_lambda_handler_30087175(event, context):
    note_id = event['queryStringParameters']['id']
    email = event['queryStringParameters']['email']
    accessToken = event['headers']['access_token']
    if not accessToken:
        return {
            'statusCode': 401,
            'body': json.dumps({'message': 'Unauthorized'})
        }

    try:
        table.delete_item(
            Key={
                'email': email,
                'id': note_id
            }
        )
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Note deleted successfully'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            "body": json.dumps({
                "message": str(e)
            })
        }
