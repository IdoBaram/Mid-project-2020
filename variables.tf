terraform {
  required_version = ">= 0.12.0"
}

variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22]
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "public_subnets" {
  default = ["10.1.10.0/24", "10.1.11.0/24"]
}

variable "private_subnets" {
  default = ["10.1.0.0/24", "10.1.1.0/24"]
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "availability_zone" {
 default = ["us-east-1a", "us-east-1b"] 
}

variable "k8_node_instance_type" {
 default = "t2.medium"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "egress_cidr_blocks" {
    default = "0.0.0.0/0"
}