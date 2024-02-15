module "web-app" {
  source = "../"
  public_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
}