terraform {
  backend "s3" {
    bucket = "kloudpepper-dev-state"
    key    = "terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "kloudpepper-dev-state"
    encrypt        = true
  }
}

### Modules ###
module "VPC" {
  source                   = "./modules/VPC"
  environment_Name         = var.environment_Name
  vpc_CIDR                 = var.vpc_CIDR
  availability_Zones       = var.availability_Zones
  public_Subnets           = var.public_Subnets
  private_Subnets          = var.private_Subnets
  create_NatGateway_1AZ    = var.create_NatGateway_1AZ
  create_NatGateway_1perAZ = var.create_NatGateway_1perAZ
  create_TransitGateway    = var.create_TransitGateway
  route_TransitGateway     = var.route_TransitGateway
}

module "NACL" {
  source             = "./modules/NACL"
  environment_Name   = var.environment_Name
  vpc_CIDR           = var.vpc_CIDR
  vpc_id             = module.VPC.vpc_id
  public_subnet_ids  = module.VPC.public_subnet_ids
  private_subnet_ids = module.VPC.private_subnet_ids
}

module "SG" {
  source           = "./modules/SG"
  environment_Name = var.environment_Name
  vpc_CIDR         = var.vpc_CIDR
  vpc_id           = module.VPC.vpc_id
}

module "VPCEndpoints" {
  source                  = "./modules/VPCEndpoints"
  aws_Region              = var.aws_Region
  environment_Name        = var.environment_Name
  vpc_id                  = module.VPC.vpc_id
  private_subnet_ids      = module.VPC.private_subnet_ids
  private_route_table_ids = module.VPC.private_route_table_ids
  vpc_endpoint_sg_id      = module.SG.vpc_endpoint_sg_id
  Services = [
    "ssmmessages",
    "monitoring",
    "ecr.api",
    "ecr.dkr",
    "secretsmanager",
    "logs"
  ]
}

module "RDS" {
  source             = "./modules/RDS"
  environment_Name   = var.environment_Name
  private_subnet_ids = module.VPC.private_subnet_ids
  rds_sg_id          = module.SG.rds_sg_id
}

module "MQ" {
  source             = "./modules/MQ"
  environment_Name   = var.environment_Name
  private_subnet_ids = module.VPC.private_subnet_ids
  mq_sg_id           = module.SG.mq_sg_id
}

module "ALB" {
  source             = "./modules/ALB"
  aws_Region         = var.aws_Region
  environment_Name   = var.environment_Name
  vpc_id             = module.VPC.vpc_id
  private_subnet_ids = module.VPC.private_subnet_ids
  alb_sg_id          = module.SG.alb_sg_id
}

# module "Route53" {
#   source              = "./modules/Route53"
#   environmentName     = var.environmentName
#   vpc_id              = module.VPC.vpc_id
#   PrivateSubnet1_id   = module.VPC.PrivateSubnet1_id
#   PrivateSubnet2_id   = module.VPC.PrivateSubnet2_id
#   ALBSecurityGroup_id = module.SG.ALBSecurityGroup_id
#   certificate_ARN     = var.certificate_ARN
# }

# module "CloudMap" {
#   source              = "./modules/CloudMap"
#   environmentName     = var.environmentName
#   vpc_id              = module.VPC.vpc_id
#   PrivateSubnet1_id   = module.VPC.PrivateSubnet1_id
#   PrivateSubnet2_id   = module.VPC.PrivateSubnet2_id
#   ALBSecurityGroup_id = module.SG.ALBSecurityGroup_id
#   certificate_ARN     = var.certificate_ARN
# }

# module "EKS" {
#   source                         = "./modules/EKS"
#   region                         = var.region
#   environmentName                = var.environmentName
#   PrivateSubnet1_id              = module.VPC.PrivateSubnet1_id
#   PrivateSubnet2_id              = module.VPC.PrivateSubnet2_id
#   ECSSecurityGroup_id            = module.SG.ECSSecurityGroup_id
#   ImageUrlWeb                    = var.ImageUrlWeb
#   ImageUrlDev                    = var.ImageUrlDev
#   ImageUrlDevL3                  = var.ImageUrlDevL3
#   ImageUrlTCUA                   = var.ImageUrlTCUA
#   ImageUrlBFL                    = var.ImageUrlBFL
#   ImageUrlApp                    = var.ImageUrlApp
#   ImageUrlBatch                  = var.ImageUrlBatch
#   TargetGroupWEB_arn             = module.ALB.TargetGroupWEB_arn
#   TargetGroupDEV_arn             = module.ALB.TargetGroupDEV_arn
#   TargetGroupDEVL3_arn           = module.ALB.TargetGroupDEVL3_arn
#   TargetGroupTCUA_arn            = module.ALB.TargetGroupTCUA_arn
#   TargetGroupAPP_arn             = module.ALB.TargetGroupAPP_arn
#   MQEnpointAddr                  = module.MQ.MQEnpointAddr
#   MQUser                         = var.MQUser
#   MQPassword                     = var.MQPassword
#   EFSFileSystem_id               = module.EFS.EFSFileSystem_id
#   AccessPoint_import-request_id  = module.EFS.AccessPoint_import-request_id
#   AccessPoint_import-response_id = module.EFS.AccessPoint_import-response_id
#   AccessPoint_import-error_id    = module.EFS.AccessPoint_import-error_id
#   AccessPoint_dw-export_id       = module.EFS.AccessPoint_dw-export_id
#   AccessPoint_dfe_id             = module.EFS.AccessPoint_dfe_id
#   AccessPoint_udexternal_id      = module.EFS.AccessPoint_udexternal_id
#   AccessPoint_cfrextract_id      = module.EFS.AccessPoint_cfrextract_id
#   AccessPoint_TAFJ_log_id        = module.EFS.AccessPoint_TAFJ_log_id
#   AccessPoint_TAFJ_logT24_id     = module.EFS.AccessPoint_TAFJ_logT24_id
#   DesiredCount                   = var.DesiredCount
# }