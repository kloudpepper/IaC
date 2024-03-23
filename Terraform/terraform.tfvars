aws_Region               = "us-east-1"
vpc_CIDR                 = "10.0.0.0/16"
availability_Zones       = 2
public_Subnets           = 2
private_Subnets          = 4
create_NatGateway_1AZ    = false
create_NatGateway_1perAZ = false
create_TransitGateway    = false
route_TransitGateway     = ""

# snapshot_ARN  = "arn:aws:rds:us-east-1:541719905654:snapshot:qa-sit-db-17112022"
# MQUser        = "tafj"
# MQPassword    = "qvkWq7*lC0uD"
# ImageUrlWeb   = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:web-R20.4.5.202211021303"
# ImageUrlDev   = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:dev-R20.4.5.202207141909"
# ImageUrlDevL3 = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:devL3-R20.4.5.202207141909"
# ImageUrlTCUA  = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:tcua-R20.4.5.202207131607"
# ImageUrlBFL   = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:bfl-R20.4.5.202207131603"
# ImageUrlApp   = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:app-R20.4.5.202211151818"
# ImageUrlBatch = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:batch-R20.4.5.202211151823"
# DesiredCount  = 0

### Tags ###
environment_Type = "dev"
environment_Name = "kloudpepper"