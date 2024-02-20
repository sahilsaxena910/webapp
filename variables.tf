variable "vpc_cidr_block" {
  description = "cidr block of the vpc"
  type        = string
}
variable "public_subnet_cidr_blocks" {
  type = list(string)
  description = "list of cidr block for public subnet(s). Enter more than one cidr if you want multiple cidr blocks"
}
variable "private_subnet_cidr_blocks" {
  type = list(string)
  description = "list of cidr block for private subnet(s). Enter more than one cidr if you want multiple cidr blocks"
}
variable "asg_max_capacity" {
  description = "maximum capacity to set for autoscaling group"
  type = number
}
variable "ebs_root_volume_size" {
  description = "size in gb for ebs root volume"
  type = number
}
variable "ebs_secondary_volume_size" {
  description = "size in gb for ebs secondary volume"
  type = number
}
variable "vpc_name" {
  description = "name of the vpc"
  default     = "web-app-vpc"
}
variable "igw_name" {
  type = string
  description = "name of the internet gatweway"
  default = "web-app-igw" 
}
variable "public_rt_name" {
  type = string
  description = "name of the public route table"
  default = "public-route-table"
}
variable "alb_sg_name" {
  type = string
  description = "name of the security group attached to the application load balancer"
  default = "alb-sg"
}
variable "ec2_sg_name" {
  type = string
  description = "name of the security group attached to the ec2 provisioned by autoscaling group"
  default = "private-instance-sg"
}
variable "asg_name" {
  type = string
  description = "name of the security group attached to the ec2 provisioned by autoscaling group"
  default = "web-app-asg"
}
variable "ec2_instance_type" {
  type = string
  description = "Instance type for ec2 instance"
  default = "t2.micro"
}
variable "key_pair_name" {
  type = string
  default = null
  description = "key pair name to to login into ec2 instance"
}
variable "asg_health_check_grace_period" {
  description = "Health check grace period for asg in seconds"
  type = number
  default = 300
}
