import boto3
import logging
from botocore.exceptions import BotoCoreError, ClientError

# Set up logging configuration
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Ensure the Lambda environment's default handler is not duplicated
for handler in logger.handlers:
    logger.removeHandler(handler)

# Add a new handler to ensure logs are sent to CloudWatch
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# Get the current API key associated with the usage plan
def get_current_api_key(client, usage_plan_id):
    logger.info(f"Getting current API key for usage plan {usage_plan_id}")
    response = client.get_usage_plan_keys(usagePlanId=usage_plan_id)
    if response['items']:
        logger.info(f"Current API key ID: {response['items'][0]['id']}")
        return response['items'][0]['id']
    else:
        logger.error("No API key found for the given usage plan")
        raise Exception("No API key found for the given usage plan")

# Create a new API key
def create_api_key(client, api_key_name):
    logger.info(f"Creating new API key with name {api_key_name}")
    response = client.create_api_key(name=api_key_name, enabled=True)
    logger.info(f"New API key ID: {response['id']}")
    return response['id']

# Delete the API key
def delete_api_key(client, key_id):
    logger.info(f"Deleting API key: {key_id}")
    response = client.delete_api_key(apiKey=key_id)
    logger.info(f"Deleted API key: {key_id}")
    return response

# Associate the API key with the usage plan
def associate_api_key_with_usage_plan(client, key_id, usage_plan_id):
    logger.info(f"Associating API key {key_id} with usage plan {usage_plan_id}")
    client.create_usage_plan_key(usagePlanId=usage_plan_id, keyId=key_id, keyType='API_KEY')
    logger.info(f"Associated API key {key_id} with usage plan {usage_plan_id}")

# Rotate the API key
def rotate_api_key(client, usage_plan_id, api_key_name):
    logger.info(f"Rotating API key for usage plan {usage_plan_id}")
    old_key_id = get_current_api_key(client, usage_plan_id)
    new_key_id = create_api_key(client, api_key_name)
    associate_api_key_with_usage_plan(client, new_key_id, usage_plan_id)
    delete_api_key(client, old_key_id)
    logger.info(f"Rotated API key. Old key ID: {old_key_id}, New key ID: {new_key_id}")
    return new_key_id

# Get the value of the new API key
def get_new_api_key_value(client, api_key_id):
    logger.info(f"Getting value for new API key ID: {api_key_id}")
    response = client.get_api_key(apiKey=api_key_id, includeValue=True)
    logger.info(f"New API key value retrieved")
    return response['value']

# Assume the role to access to API Gateway in target account
def assume_role(role_arn, session_name):
    logger.info(f"Assuming role {role_arn} with session name {session_name}")
    sts_client = boto3.client('sts')
    assumed_role_object = sts_client.assume_role(
        RoleArn=role_arn,
        RoleSessionName=session_name
    )
    logger.info(f"Assumed role {role_arn}")
    return assumed_role_object['Credentials']

# Main Lambda handler
def lambda_handler(event, context):
    try:
        # Extract variables from event JSON
        role_arn = event['API_GATEWAY_ROLE_ARN']
        usage_plan_id = event['USAGE_PLAN_ID']
        distribution_id = event['DISTRIBUTION_ID']
        origin_id = event['ORIGIN_ID']
        api_key_name = event['API_KEY_NAME']

        session_name = 'api_gateway_update_session'
        credentials = assume_role(role_arn, session_name)

        # Create a new API Gateway client using the assumed role credentials
        client = boto3.client(
            'apigateway',
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['SessionToken']
        )

        new_key_id = rotate_api_key(client, usage_plan_id, api_key_name)
        new_key_value = get_new_api_key_value(client, new_key_id)

        # Create a new CloudFront client directly
        cloudfront = boto3.client('cloudfront')

        # Get the current distribution configuration
        distribution_config_response = cloudfront.get_distribution_config(Id=distribution_id)
        distribution_config = distribution_config_response['DistributionConfig']

        # Modify the custom header in the origin
        for origin in distribution_config['Origins']['Items']:
            if origin['Id'] == origin_id:
                origin['CustomHeaders'] = {
                    'Quantity': 1,
                    'Items': [
                        {
                            'HeaderName': 'x-api-key',
                            'HeaderValue': new_key_value
                        }
                    ]
                }

        # Update the distribution configuration
        cloudfront.update_distribution(
            Id=distribution_id,
            IfMatch=distribution_config_response['ETag'],
            DistributionConfig=distribution_config
        )
        logger.info(f'Custom Header rotated successfully.')

        return {
            'statusCode': 200,
            'body': f'API key and custom header rotated successfully. New API key ID is {new_key_id}.'
        }

    except ValueError as ve:
        logger.error(f"Configuration error: {ve}")
    except (BotoCoreError, ClientError) as aws_error:
        logger.error(f"AWS service error: {aws_error}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")