variable "vpc_cidr_block" {
    description = "cidr block of the vpc"
    type = string
    default = "10.0.0.0/16"
}
variable "vpc_name" {
    description = "name of the vpc"
}