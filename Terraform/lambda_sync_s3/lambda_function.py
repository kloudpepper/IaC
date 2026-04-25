import boto3
import os
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

def sync_s3_buckets(source_bucket, destination_bucket):
    s3 = boto3.client('s3')
    s3_resource = boto3.resource('s3')

    # Extract bucket names and prefixes
    source_bucket_name, source_prefix = extract_bucket_and_prefix(source_bucket)
    destination_bucket_name, destination_prefix = extract_bucket_and_prefix(destination_bucket)

    try:
        # List objects in the source bucket with the specified prefix
        source_objects = s3.list_objects_v2(Bucket=source_bucket_name, Prefix=source_prefix)
        source_keys = set(obj['Key'] for obj in source_objects.get('Contents', []))

        # Check if the source bucket is empty
        if not source_keys:
            print(f"The source bucket {source_bucket_name} is empty or has no objects with the prefix {source_prefix}.")
            return

        # List objects in the destination bucket with the specified prefix
        destination_objects = s3.list_objects_v2(Bucket=destination_bucket_name, Prefix=destination_prefix)
        destination_keys = set(obj['Key'] for obj in destination_objects.get('Contents', []))

        # Copy objects from source to destination if they don't exist or are updated
        for key in source_keys:
            # Skip directories or prefixes
            if key.endswith('/'):
                continue

            copy_source = {'Bucket': source_bucket_name, 'Key': key}
            destination_key = key.replace(source_prefix, destination_prefix, 1)
            try:
                dest_obj = s3.head_object(Bucket=destination_bucket_name, Key=destination_key)
                source_obj = s3.head_object(Bucket=source_bucket_name, Key=key)
                if source_obj['LastModified'] > dest_obj['LastModified']:
                    s3_resource.Object(destination_bucket_name, destination_key).copy(copy_source)
                    print(f"Copied {key} from {source_bucket} to {destination_bucket}")
                    try:
                        s3.delete_object(Bucket=source_bucket_name, Key=key)
                        print(f"Deleted {key} from {source_bucket}")
                    except Exception as e:
                        print(f"Failed to delete {key} from {source_bucket}: {e}")
                else:
                    print(f"Object {key} is up-to-date in {destination_bucket}, skipping.")
            except s3.exceptions.ClientError:
                s3_resource.Object(destination_bucket_name, destination_key).copy(copy_source)
                print(f"Copied {key} from {source_bucket} to {destination_bucket}")
                try:
                    s3.delete_object(Bucket=source_bucket_name, Key=key)
                    print(f"Deleted {key} from {source_bucket}")
                except Exception as e:
                    print(f"Failed to delete {key} from {source_bucket}: {e}")

    except NoCredentialsError:
        print("Credentials not available")
    except PartialCredentialsError:
        print("Incomplete credentials provided")
    except Exception as e:
        print(f"An error occurred: {e}")

def extract_bucket_and_prefix(bucket_with_prefix):
    parts = bucket_with_prefix.split('/', 1)
    bucket_name = parts[0]
    prefix = parts[1] if len(parts) > 1 else ''
    return bucket_name, prefix

def lambda_handler(event, context):
    source_bucket = os.environ.get('SRC_BUCKET')
    destination_bucket = os.environ.get('DST_BUCKET')

    if not source_bucket or not destination_bucket:
        print("Source or destination bucket environment variables are not set.")
        return {
            'statusCode': 400,
            'body': 'Source or destination bucket environment variables are not set.'
        }

    print(f"Starting sync from {source_bucket} to {destination_bucket}")
    sync_s3_buckets(source_bucket, destination_bucket)
    print("Sync completed successfully")
    return {
        'statusCode': 200,
        'body': 'Sync completed successfully'
    }