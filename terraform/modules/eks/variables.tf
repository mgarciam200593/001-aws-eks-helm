variable "cluster_name" {
  type    = string
  default = "demo_eks_cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.26"
}

variable "cluster_enabled_log_types" {
  type    = list(string)
  default = []
}

variable "iam_role_arn" {
  type    = string
  default = null
}

variable "cluster_security_groups" {
  type    = list(string)
  default = []
}

variable "cluster_subnet_ids" {
  type    = list(string)
  default = []
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = false
}

variable "cluster_public_access_cidrs" {
  type    = list(string)
  default = []
}

variable "enable_irsa" {
  type    = bool
  default = false
}

variable "openid_connect_audiences" {
  type    = list(string)
  default = []
}

variable "custom_oidc_thumbprints" {
  type    = list(string)
  default = []
}

variable "create_iam_role" {
  type    = bool
  default = false
}

variable "nodes_iam_role_arn" {
  type    = string
  default = null
}

variable "node_group_name" {
  type    = string
  default = "demo_eks_node_group"
}

variable "instance_types" {
  type    = list(string)
  default = []
}

variable "ami_type" {
  type    = string
  default = "AL2_x86_64"
}

variable "release_version" {
  type    = string
  default = "1.27.3-20230728"
}

variable "desired_size" {
  type    = number
  default = 0
}

variable "max_size" {
  type    = number
  default = 0
}

variable "min_size" {
  type    = number
  default = 0
}

variable "enable_remote_access" {
  type    = bool
  default = false
}

variable "ec2_ssh_key" {
  type    = string
  default = null
}

variable "cluster_tags" {
  type    = map(string)
  default = {}
}

variable "node_tags" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}


