##################
### EKS Module ###
##################

# Create log group for EKS cluster
resource "aws_cloudwatch_log_group" "logs_cluster" {
  name              = "/aws/eks/${environment_Name}-eks-cluster/cluster"
  retention_in_days = 7
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "cluster_iam_role" {
  name = "${environment_Name}-ClusterRole"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_iam_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_iam_role.name
}


# Create IAM role for EKS pods
resource "aws_iam_role" "pods_iam_role" {
  name = "${environment_Name}-PodExecutionRole"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.pods_iam_role.name
}


# Create EKS cluster
resource "aws_eks_cluster" "cluster" {
  depends_on = [aws_cloudwatch_log_group.logs_cluster]
  name       = "${environment_Name}-eks-cluster"
  role_arn   = aws_iam_role.cluster.arn
  vpc_config {
    subnet_ids              = length(var.private_subnet_ids) == 4 ? slice(var.private_subnet_ids, 0, 2) : length(var.private_subnet_ids) == 6 ? slice(var.private_subnet_ids, 0, 2, 4) : var.private_subnet_ids
    security_group_ids      = [var.eks_sg_id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }
  enabled_cluster_log_types = ["api", "audit"]
  tags = {
    "Name" = "${environment_Name}-eks-cluster"
  }

}


# Create Fargate profile
resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "${environment_Name}-fargate_profile"
  pod_execution_role_arn = aws_iam_role.pods_iam_role.arn
  subnet_ids             = length(var.private_subnet_ids) == 4 ? slice(var.private_subnet_ids, 0, 2) : length(var.private_subnet_ids) == 6 ? slice(var.private_subnet_ids, 0, 2, 4) : var.private_subnet_ids

  selector {
    namespace = "${environment_Name}-eks"
  }
}