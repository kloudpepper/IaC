aws_Region               = "us-east-1"
vpc_CIDR                 = "10.0.0.0/16"
availability_Zones       = 2
public_Subnets           = 2
private_Subnets          = 4
create_NatGateway_1AZ    = true
create_NatGateway_1perAZ = false
create_TransitGateway    = false
route_TransitGateway     = ""
docker_image             = "public.ecr.aws/docker/library/nginx:alpine"

### Tags ###
environment_Type = "dev"
environment_Name = "kloudpepper"