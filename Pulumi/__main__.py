import json
import pulumi
import pulumi_aws as aws
import pulumi_aws_apigateway as apigateway

with open("parameters.json") as f:
    parameters = json.load(f)

#### Create a S3 Bucket ####
# Create an AWS resource (S3 Bucket)
bucket = aws.s3.Bucket((parameters["default"][0]["Environment_Name"]) + '-pulumi-bucket')

pulumi.export('bucket_arn', bucket.arn)


### Create a SQS Queue ###
queue = aws.sqs.Queue((parameters["default"][0]["Environment_Name"]) + '-pulumi-queue')

pulumi.export('queue_arn', queue.arn)


### Create a DynamoDB Table ###
table = aws.dynamodb.Table((parameters["default"][0]["Environment_Name"]) + '-pulumi-table',
    attributes=[
        aws.dynamodb.TableAttributeArgs(
            name='id',
            type='S',
        ),
    ],
    hash_key='id',
    read_capacity=1,
    write_capacity=1)

pulumi.export('table_arn', table.arn)


#### Create a Lambda Function ####
# An execution role to use for the Lambda function
role = aws.iam.Role((parameters["default"][0]["Environment_Name"]) + '-pulumi-lambda-role',
    assume_role_policy=json.dumps({
        "Version": "2012-10-17",
        "Statement": [{
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com",
            },
        }],
    }),
    managed_policy_arns=[aws.iam.ManagedPolicy.AWS_LAMBDA_BASIC_EXECUTION_ROLE])

# A Lambda function to invoke
fn = aws.lambda_.Function((parameters["default"][0]["Environment_Name"]) + '-pulumi-lambda',
    runtime="python3.11",
    handler="handler.handler",
    role=role.arn,
    code=pulumi.FileArchive("./function"))


#### Create an API Gateway ####
api = apigateway.RestAPI((parameters["default"][0]["Environment_Name"]) + '-pulumi-api',
    routes=[
    apigateway.RouteArgs(path="/", local_path="www"),
    apigateway.RouteArgs(path="/date", method=apigateway.Method.GET, event_handler=fn)
    ])

pulumi.export("url", api.url)