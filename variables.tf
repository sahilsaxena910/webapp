variable "vpc_cidr_block" {
  description = "cidr block of the vpc"
  type        = string
  default     = "10.0.0.0/16"
}
variable "vpc_name" {
  description = "name of the vpc"
  default     = "web-app-vpc"
}
variable "public_subnet_cidr_blocks" {
  description = "list of cidr block for public subnet(s). Enter more than one cidr if you want multiple cidr blocks"
}
variable "private_subnet_cidr_blocks" {
  description = "list of cidr block for private subnet(s). Enter more than one cidr if you want multiple cidr blocks"
}
variable "asg_desired_capacity" {
  type = number
}
variable "asg_min_capacity" {
  type = number
}
variable "asg_max_capacity" {
  type = number
}
variable "ebs_root_volume_size" {
  type = number
}
variable "ebs_secondary_volume_size" {
  type = number
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
variable "isDocker" {
  type    = bool
  default = false
}
