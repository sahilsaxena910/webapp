module "web-app" {
  source                     = "../"
  vpc_cidr_block = "10.0.0.0/16"
  public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
  asg_max_capacity = 5
  ebs_root_volume_size = 20
  ebs_secondary_volume_size = 20
  asg_health_check_grace_period = 300
}