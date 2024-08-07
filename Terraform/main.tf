###############
### Modules ###
###############

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

module "CloudMap" {
  source           = "./modules/CloudMap"
  environment_Name = var.environment_Name
  vpc_id           = module.VPC.vpc_id
}

module "ECS" {
  source                    = "./modules/ECS"
  environment_Name          = var.environment_Name
  private_subnet_ids        = module.VPC.private_subnet_ids
  ecs_sg_id                 = module.SG.ecs_sg_id
  docker_image              = var.docker_image
  web_target_group_arn      = module.ALB.web_target_group_arn
  app_target_group_arn      = module.ALB.app_target_group_arn
  mq_endpoint               = module.MQ.mq_endpoint
  mq_password_arn           = module.MQ.mq_password_arn
  db_url                    = module.RDS.db_url
  aws_Region                = var.aws_Region
  private_dns_namespace_arn = module.CloudMap.private_dns_namespace_arn
  web_discovery_service_arn = module.CloudMap.web_discovery_service_arn
  app_discovery_service_arn = module.CloudMap.app_discovery_service_arn
}