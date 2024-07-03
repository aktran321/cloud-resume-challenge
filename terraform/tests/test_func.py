import json
import boto3
from moto import mock_dynamodb2
import pytest

# Import lambda_handler from aws_lambda/func.py
from aws_lambda.func import lambda_handler

@pytest.fixture(scope='function')
def dynamodb_table():
    with mock_dynamodb2():
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        table = dynamodb.create_table(
            TableName='cloud-resume-challenge',
            KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
            AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
            ProvisionedThroughput={'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1}
        )
        table.meta.client.get_waiter('table_exists').wait(TableName='cloud-resume-challenge')
        yield table
        table.delete()

def test_lambda_handler(dynamodb_table):
    dynamodb_table.put_item(Item={"id": "1", "views": 5})
    event = {}
    context = {}
    response = lambda_handler(event, context)
    assert response['statusCode'] == 200
    body = json.loads(response['body'])
    assert body['views'] == 6
    updated_item = dynamodb_table.get_item(Key={"id": "1"}).get('Item')
    assert updated_item['views'] == 6

def test_lambda_handler_no_item(dynamodb_table):
    event = {}
    context = {}
    response = lambda_handler(event, context)
    assert response['statusCode'] == 200
    body = json.loads(response['body'])
    assert body['views'] == 1
    updated_item = dynamodb_table.get_item(Key={"id": "1"}).get('Item')
    assert updated_item['views'] == 1
