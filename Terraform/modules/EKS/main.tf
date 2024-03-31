resource "aws_eks_cluster" "EKSCluster" {
    name = "kloudpepper"
    role_arn = "arn:aws:iam::839975170650:role/eksClusterRole"
    version = "1.29"
    vpc_config {
        security_group_ids = [
            "sg-0af8c51ace0b76d81"
        ]
        subnet_ids = [
            "subnet-0aa48a0e64ef866c4",
            "subnet-0781c972dae49a63d"
        ]
    }
}
