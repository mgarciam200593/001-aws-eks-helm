# EKS Cluster Module
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  cluster_role = try(aws_iam_role.eks_role[0].arn, var.iam_role_arn)
  nodes_role   = try(aws_iam_role.node_role[0].arn, var.nodes_iam_role_arn)
}


# EKS Cluster
###########################################################################
resource "aws_eks_cluster" "this" {
  name                      = var.cluster_name
  role_arn                  = local.cluster_role
  version                   = var.cluster_version
  enabled_cluster_log_types = var.cluster_enabled_log_types

  vpc_config {
    security_group_ids      = var.cluster_security_groups
    subnet_ids              = var.cluster_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_public_access_cidrs
  }

  tags = merge(
    { Name = var.cluster_name },
    var.tags,
    var.cluster_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.this
  ]
}

resource "aws_ec2_tag" "subnet_cluster_owner_tag" {
  count = length(var.cluster_subnet_ids)

  resource_id = var.cluster_subnet_ids[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "owned"
}

resource "aws_ec2_tag" "subnet_cluster_lb_tag" {
  count = length(var.cluster_subnet_ids)

  resource_id = var.cluster_subnet_ids[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

# EKS IRSA
###########################################################################
data "tls_certificate" "this" {
  count = var.enable_irsa ? 1 : 0

  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count = var.enable_irsa ? 1 : 0

  client_id_list  = distinct(compact(concat(["sts.${data.aws_partition.current.dns_suffix}"], var.openid_connect_audiences)))
  thumbprint_list = concat(data.tls_certificate.this[0].certificates[*].sha1_fingerprint, var.custom_oidc_thumbprints)
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(
    { Name = "${var.cluster_name}-eks-irsa" },
    var.tags
  )
}

# EKS IAM Role
###########################################################################
data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create_iam_role ? 1 : 0

  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "eks_role" {
  count = var.create_iam_role ? 1 : 0

  name               = "${var.cluster_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy[0].json
}

resource "aws_iam_role_policy_attachment" "this" {
  count = var.create_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role[0].name
}

# EKS Managed Nodes
###########################################################################
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = local.nodes_role

  subnet_ids      = var.cluster_subnet_ids
  capacity_type   = "ON_DEMAND"
  instance_types  = var.instance_types
  ami_type        = var.ami_type
  release_version = var.release_version

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  dynamic "remote_access" {
    for_each = var.enable_remote_access ? [true] : []

    content {
      ec2_ssh_key = var.ec2_ssh_key
    }
  }

  tags = merge(
    { Name = var.cluster_name },
    var.tags,
    var.node_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly
  ]
}

# EKS Managed Nodes Role
###########################################################################
data "aws_iam_policy_document" "nodes_role_policy" {
  count = var.create_iam_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "node_role" {
  count = var.create_iam_role ? 1 : 0

  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.nodes_role_policy[0].json
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  count = var.create_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role[0].name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  count = var.create_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role[0].name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  count = var.create_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role[0].name
}