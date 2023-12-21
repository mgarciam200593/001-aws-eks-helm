# EKS Cluster
###########################################################################
output "eks_cluster_name" {
  value       = aws_eks_cluster.this.id
  description = "EKS Cluster Name"
}

output "eks_cluster_arn" {
  value       = aws_eks_cluster.this.arn
  description = "EKS Cluster ARN"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "EKS Cluster Endpoint"
}

output "eks_cluster_platform_version" {
  value       = aws_eks_cluster.this.platform_version
  description = "EKS Cluster Platform Version"
}

# EKS Managed Nodes
###########################################################################
output "eks_node_group_name" {
  value       = aws_eks_node_group.this.id
  description = "EKS Cluster Managed Node Group Name"
}

output "eks_node_group_arn" {
  value       = aws_eks_node_group.this.arn
  description = "EKS Cluster Managed Node Group ARN"
}