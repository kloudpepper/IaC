
environmentName                     = "kloudpepper"
environmentType                     = "DEV"
aws_Region                          = "us-east-1"
vpc_CIDR                            = "10.99.98.0/24"
availability_Zones                  = 1
private_subnet_CIDRs                = ["10.99.98.0/26", "10.99.98.64/26"]
transit_gateway_ID                  = "tgw-07628b18fc15085bc"
create_igw                          = false
create_transit_gateway_attachment   = true
ip_nat_IIB_onpremise                = "10.100.1.10"
certificate_ARN                     = "arn:aws:acm:us-east-1:541719905654:certificate/82bf3e60-6ef5-47f8-876f-b4b45120ca26"
snapshot_ARN                        = "arn:aws:rds:us-east-1:541719905654:snapshot:qa-sit-db-17112022"
MQUser                              = "tafj"
MQPassword                          = "qvkWq7*lC0uD"
ImageUrlWeb                         = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:web-R20.4.5.202211021303"
ImageUrlDev                         = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:dev-R20.4.5.202207141909"
ImageUrlDevL3                       = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:devL3-R20.4.5.202207141909"
ImageUrlTCUA                        = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:tcua-R20.4.5.202207131607"
ImageUrlBFL                         = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:bfl-R20.4.5.202207131603"
ImageUrlApp                         = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:app-R20.4.5.202211151818"
ImageUrlBatch                       = "541719905654.dkr.ecr.us-east-1.amazonaws.com/images:batch-R20.4.5.202211151823"
DesiredCount                        = 0

### Tags ###
Env                                 = "PRD"