variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "263742094725"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (Ubuntu 22.04 in eu-north-1)"
  type        = string
  default     = "ami-0989fb15ce71ba39e"
}