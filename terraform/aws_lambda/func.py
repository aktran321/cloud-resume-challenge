import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("cloud-resume-challenge")

def lambda_handler(event, context):
    try:
        # Get the current view count from DynamoDB
        response = table.get_item(Key={
            "id": "1"
        })
        if 'Item' in response:
            views = int(response["Item"]["views"])
        else:
            views = 0  # Default to 0 if the item doesn't exist
        
        # Increment the view count
        views += 1
        print("pushed with terraform!")
        print(views)
        
        # Update the view count in DynamoDB
        table.put_item(Item={
            "id": "1",
            "views": views
        })
        
        # Return the updated view count with headers
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"views": views})
        }
    
    except Exception as e:
        print(f"Error: {e}")
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }
