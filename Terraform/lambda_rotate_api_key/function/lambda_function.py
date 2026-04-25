import boto3
import logging
from botocore.exceptions import BotoCoreError, ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Remove default handlers to avoid duplicate logging
for h in logger.handlers:
    logger.removeHandler(h)

# Add a stream handler for CloudWatch logging
stream_handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)


def get_existing_api_key(client, usage_plan_id):
    """
    Returns the existing API key ID for the given usage plan, or None if not found.
    """
    logger.info("Retrieving current API key for usage plan '%s'", usage_plan_id)
    response = client.get_usage_plan_keys(usagePlanId=usage_plan_id)
    keys = response.get('items', [])
    if keys:
        # Return the very first API key ID if any exist
        api_key_id = keys[0]['id']
        logger.info("Found current API key: %s", api_key_id)
        return api_key_id
    else:
        logger.info("No API key found for usage plan '%s'", usage_plan_id)
        return None


def create_api_key(client, api_key_name):
    """
    Creates a new, enabled API key with the provided name.
    Returns the new key's ID.
    """
    logger.info("Creating new API key '%s'", api_key_name)
    response = client.create_api_key(name=api_key_name, enabled=True)
    new_api_key_id = response.get('id')
    logger.info("New API key created. ID: %s", new_api_key_id)
    return new_api_key_id


def delete_api_key(client, key_id):
    """
    Deletes the specified API key by ID.
    """
    logger.info("Deleting API key '%s'", key_id)
    client.delete_api_key(apiKey=key_id)
    logger.info("Deleted API key '%s'", key_id)


def associate_api_key_with_usage_plan(client, key_id, usage_plan_id):
    """
    Associates the specified API key with the provided usage plan.
    """
    logger.info("Associating API key '%s' with usage plan '%s'", key_id, usage_plan_id)
    client.create_usage_plan_key(usagePlanId=usage_plan_id, keyId=key_id, keyType='API_KEY')
    logger.info("Associated API key '%s' with usage plan '%s'", key_id, usage_plan_id)


def rotate_or_create_api_key(client, usage_plan_id, api_key_name):
    """
    Checks if an API key exists for the specified usage plan.
    If it does, rotates the key by creating a new one, associating it, and deleting the old one.
    If it does not, creates a new key and associates it with the usage plan.
    Returns the new (or newly associated) key ID.
    """
    logger.info("Checking for existing API key on usage plan '%s'", usage_plan_id)
    old_key_id = get_existing_api_key(client, usage_plan_id)

    if old_key_id:
        # Rotate
        logger.info("Existing API key found. Proceeding with key rotation.")
        new_key_id = create_api_key(client, api_key_name)
        associate_api_key_with_usage_plan(client, new_key_id, usage_plan_id)
        delete_api_key(client, old_key_id)
        logger.info("Rotated API key; old key '%s', new key '%s'", old_key_id, new_key_id)
        return new_key_id
    else:
        # Create if none found
        logger.info("No API key found for usage plan '%s'. Creating and associating a new key.", usage_plan_id)
        new_key_id = create_api_key(client, api_key_name)
        associate_api_key_with_usage_plan(client, new_key_id, usage_plan_id)
        logger.info("Created new API key '%s' and associated with usage plan '%s'", new_key_id, usage_plan_id)
        return new_key_id


def get_new_api_key_value(client, api_key_id):
    """
    Retrieves the 'value' of a newly created API key by its ID.
    """
    logger.info("Getting value for API key '%s'", api_key_id)
    response = client.get_api_key(apiKey=api_key_id, includeValue=True)
    value = response.get('value')
    logger.info("Retrieved API key value.")
    return value


def lambda_handler(event, context):
    """
    Main AWS Lambda handler: creates or rotates the API key, then updates CloudFront distribution with new key header.
    """
    try:
        usage_plan_id   = event['USAGE_PLAN_ID']
        distribution_id = event['DISTRIBUTION_ID']
        origin_id       = event['ORIGIN_ID']
        api_key_name    = event['API_KEY_NAME']

        apigw_client = boto3.client('apigateway')
        cloudfront   = boto3.client('cloudfront')

        # Either rotate the key if it exists, or create if none
        new_key_id    = rotate_or_create_api_key(apigw_client, usage_plan_id, api_key_name)
        new_key_value = get_new_api_key_value(apigw_client, new_key_id)

        # Fetch distribution config
        logger.info("Fetching distribution config for '%s'", distribution_id)
        dist_config_response = cloudfront.get_distribution_config(Id=distribution_id)
        dist_config = dist_config_response['DistributionConfig']

        # Update the origin custom header
        for origin in dist_config['Origins']['Items']:
            if origin['Id'] == origin_id:
                logger.info("Updating 'x-api-key' header for origin '%s'", origin_id)
                origin['CustomHeaders'] = {
                    'Quantity': 1,
                    'Items': [{
                        'HeaderName':  'x-api-key',
                        'HeaderValue': new_key_value
                    }]
                }

        # Update the distribution
        logger.info("Updating distribution '%s' with new API key header", distribution_id)
        cloudfront.update_distribution(
            Id=distribution_id,
            IfMatch=dist_config_response['ETag'],
            DistributionConfig=dist_config
        )

        logger.info("API key processed and CloudFront distribution updated successfully.")
        return {
            'statusCode': 200,
            'body': f"New or rotated API key (ID: {new_key_id}) is now active."
        }

    except KeyError as e:
        logger.error("Missing mandatory field in event: %s", e)
        return {
            'statusCode': 400,
            'body': f"Missing field: {str(e)}"
        }
    except ValueError as ve:
        logger.error("Configuration error: %s", ve)
        return {
            'statusCode': 400,
            'body': f"Configuration error: {str(ve)}"
        }
    except (BotoCoreError, ClientError) as aws_err:
        logger.error("AWS error: %s", aws_err)
        return {
            'statusCode': 500,
            'body': f"AWS error: {str(aws_err)}"
        }
    except Exception as e:
        logger.error("Unexpected error: %s", e)
        return {
            'statusCode': 500,
            'body': f"Unexpected error: {str(e)}"
        }