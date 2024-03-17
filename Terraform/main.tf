terraform {
    backend "s3" {
        bucket          = "kloudpepper-test-state"
        key             = "terraform.tfstate"
        region          = "us-east-1"

        dynamodb_table  = "kloudpepper-test-state"
        encrypt         = true
    }
}

### Modules ###
module "VPC" {
    source = "./modules/VPC"
    environment_Name                       = var.environment_Name
    vpc_CIDR                              = var.vpc_CIDR
    create_igw                            = var.create_igw
}

module "NACL" {
    source = "./modules/NACL"
    environmentName                       = var.environmentName
    vpc_CIDR                              = var.vpc_CIDR
    vpc_id                                = module.VPC.vpc_id
}

module "SG" {
    source = "./modules/SG"
    environmentName                       = var.environmentName
    vpc_CIDR                              = var.vpc_CIDR
    vpc_id                                = module.VPC.vpc_id
}

module "VPCEndpoints" {
    source = "./modules/VPCEndpoints"
    region                                = var.aws_Region
    environmentName                       = var.environmentName
    vpc_id                                = module.VPC.vpc_id
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    PrivateRouteTable_id                  = module.VPC.PrivateRouteTable_id
    VPCEnpointSecurityGroup_id            = module.SG.VPCEnpointSecurityGroup_id
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
    source = "./modules/RDS"
    environmentName                       = var.environmentName
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    RDSSecurityGroup_id                   = module.SG.RDSSecurityGroup_id
    snapshot_ARN                          = var.snapshot_ARN
}

module "MQ" {
    source = "./modules/MQ"
    environmentName                       = var.environmentName
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    MQSecurityGroup_id                    = module.SG.MQSecurityGroup_id
    MQUser                                = var.MQUser
    MQPassword                            = var.MQPassword
}

module "ALB" {
    source = "./modules/ALB"
    environmentName                       = var.environmentName
    vpc_id                                = module.VPC.vpc_id
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    ALBSecurityGroup_id                   = module.SG.ALBSecurityGroup_id
    certificate_ARN                       = var.certificate_ARN
}

module "Route53" {
    source = "./modules/Route53"
    environmentName                       = var.environmentName
    vpc_id                                = module.VPC.vpc_id
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    ALBSecurityGroup_id                   = module.SG.ALBSecurityGroup_id
    certificate_ARN                       = var.certificate_ARN
}

module "CloudMap" {
    source = "./modules/CloudMap"
    environmentName                       = var.environmentName
    vpc_id                                = module.VPC.vpc_id
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    ALBSecurityGroup_id                   = module.SG.ALBSecurityGroup_id
    certificate_ARN                       = var.certificate_ARN
}

module "EKS" {
    source = "./modules/EKS"
    region                                = var.region
    environmentName                       = var.environmentName
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    ECSSecurityGroup_id                   = module.SG.ECSSecurityGroup_id
    ImageUrlWeb                           = var.ImageUrlWeb
    ImageUrlDev                           = var.ImageUrlDev
    ImageUrlDevL3                         = var.ImageUrlDevL3
    ImageUrlTCUA                          = var.ImageUrlTCUA
    ImageUrlBFL                           = var.ImageUrlBFL
    ImageUrlApp                           = var.ImageUrlApp
    ImageUrlBatch                         = var.ImageUrlBatch
    TargetGroupWEB_arn                    = module.ALB.TargetGroupWEB_arn
    TargetGroupDEV_arn                    = module.ALB.TargetGroupDEV_arn
    TargetGroupDEVL3_arn                  = module.ALB.TargetGroupDEVL3_arn
    TargetGroupTCUA_arn                   = module.ALB.TargetGroupTCUA_arn
    TargetGroupAPP_arn                    = module.ALB.TargetGroupAPP_arn
    MQEnpointAddr                         = module.MQ.MQEnpointAddr
    MQUser                                = var.MQUser
    MQPassword                            = var.MQPassword
    EFSFileSystem_id                      = module.EFS.EFSFileSystem_id
    AccessPoint_import-request_id         = module.EFS.AccessPoint_import-request_id
    AccessPoint_import-response_id        = module.EFS.AccessPoint_import-response_id
    AccessPoint_import-error_id           = module.EFS.AccessPoint_import-error_id
    AccessPoint_dw-export_id              = module.EFS.AccessPoint_dw-export_id
    AccessPoint_dfe_id                    = module.EFS.AccessPoint_dfe_id
    AccessPoint_udexternal_id             = module.EFS.AccessPoint_udexternal_id
    AccessPoint_cfrextract_id             = module.EFS.AccessPoint_cfrextract_id
    AccessPoint_TAFJ_log_id               = module.EFS.AccessPoint_TAFJ_log_id
    AccessPoint_TAFJ_logT24_id            = module.EFS.AccessPoint_TAFJ_logT24_id
    DesiredCount                          = var.DesiredCount
}