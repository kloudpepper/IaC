terraform {
    backend "s3" {
        bucket          = "state-terra-core-bancario"
        key             = "principal/terraform.tfstate"
        region          = "us-east-1"

        dynamodb_table  = "state-terra-core-bancario-principal"
        encrypt         = true
        profile         = "580261040628_AWSAdministratorAccess"
    }
}

### Modules ###
module "VPC" {
    source = "./modules/VPC"
    environmentName                       = var.environmentName
    vpc_CIDR                              = var.vpc_CIDR
    private_subnet_1_CIDR                 = var.private_subnet_1_CIDR
    private_subnet_2_CIDR                 = var.private_subnet_2_CIDR
    reserved_subnet_CIDR                  = var.reserved_subnet_CIDR
    transit_gateway_ID                    = var.transit_gateway_ID
    create_igw                            = var.create_igw
    create_transit_gateway_attachment     = var.create_transit_gateway_attachment
}

module "SG" {
    source = "./modules/SG"
    environmentName                       = var.environmentName
    vpc_CIDR                              = var.vpc_CIDR
    vpc_id                                = module.VPC.vpc_id
}

module "VPCEndpoints" {
    source = "./modules/VPCEndpoints"
    region                                = var.region
    environmentName                       = var.environmentName
    vpc_id                                = module.VPC.vpc_id
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    PrivateRouteTable_id                  = module.VPC.PrivateRouteTable_id
    VPCEnpointSecurityGroup_id            = module.SG.VPCEnpointSecurityGroup_id
    Services = [
        "ec2",
        "ssm",
        "ssmmessages",
        "ec2messages",
        "events",
        "sns",
        "monitoring",
        "ecr.api",
        "ecr.dkr",
        "application-autoscaling",
        "secretsmanager",
        "logs",
        "s3"
    ]
}

module "S3" {
    source = "./modules/S3"
    environmentName                       = var.environmentName
}

module "EFS" {
    source = "./modules/EFS"
    environmentName                       = var.environmentName
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    EFSSecurityGroup_id                   = module.SG.EFSSecurityGroup_id
}

module "SFTP" {
    source = "./modules/SFTP"
    environmentName                       = var.environmentName
    vpc_id                                = module.VPC.vpc_id
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    SFTPSecurityGroup_id                  = module.SG.SFTPSecurityGroup_id
}

module "NLB" {
    source = "./modules/NLB"
    environmentName                       = var.environmentName
    vpc_id                                = module.VPC.vpc_id
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    ip_nat_IIB_onpremise                  = var.ip_nat_IIB_onpremise
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

/* module "RDS" {
    source = "./modules/RDS"
    environmentName                       = var.environmentName
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    RDSSecurityGroup_id                   = module.SG.RDSSecurityGroup_id
    snapshot_ARN                          = var.snapshot_ARN
} */

module "MQ" {
    source = "./modules/MQ"
    environmentName                       = var.environmentName
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    MQSecurityGroup_id                    = module.SG.MQSecurityGroup_id
    MQUser                                = var.MQUser
    MQPassword                            = var.MQPassword
}

module "ECS" {
    source = "./modules/ECS"
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

module "Lambda" {
    source = "./modules/Lambda"
    environmentName                       = var.environmentName
    PrivateSubnet1_id                     = module.VPC.PrivateSubnet1_id
    PrivateSubnet2_id                     = module.VPC.PrivateSubnet2_id
    LambdaSecurityGroup_id                = module.SG.LambdaSecurityGroup_id
}