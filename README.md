Terraform Module: Deploys a simple web app using AWS VPC with Load Balancer
This Terraform module sets up an AWS Virtual Private Cloud (VPC) with public and private subnets, an Application Load Balancer (ALB), and associated resources. It also includes Auto Scaling for EC2 instances and CloudWatch Alarms for monitoring.

Important Design Decisions
. Application code is stored in a seperate repository because of seperation of concerns: https://github.com/sahilsaxena910/simpleapp
. Autoscaling group minimum capacity is hardcoded within the module to 1 so that at any given point in time we must have atleast once instance up and running to host the web app. 

Features
VPC Configuration: Create a VPC with specified CIDR block, DNS support, and DNS hostnames.
Subnets: Create public and private subnets across multiple availability zones.
Internet Gateway: Attach an Internet Gateway to the VPC for public subnet internet access.
Route Tables: Set up public and private route tables with appropriate routes.
Security Groups: Define security groups for ALB and EC2 instances with customizable ingress and egress rules. For security reasons the security group of EC2 instances only allow traffic from security group of ALB.
ALB: Create an Application Load Balancer with HTTP and HTTPS listeners.
Auto Scaling: Configure Auto Scaling for EC2 instances in private subnets.
CloudWatch Alarms: Set up alarms for CPU utilization to trigger Auto Scaling policies.
DNS Configuration: Create a private Route 53 hosted zone and associate it with the VPC. Configure a CNAME record for the ALB.
SSL Certificate: Generate a self-signed SSL certificate for HTTPS traffic.
Nat Gateway: Allows outbound traffic to internet for instances launched in private subnet.

For module usage please take a look at examples section

Inputs
. vpc_cidr_block (required): The CIDR block for the VPC.
. public_subnet_cidr_blocks (required): List of CIDR blocks for public subnets.
. private_subnet_cidr_blocks (required): List of CIDR blocks for private subnets.

Outputs
alb_dns_name: DNS name of the Application Load Balancer.

Important Notes
Ensure that necessary AWS credentials and permissions are set up before applying the Terraform configuration.
The generated SSL certificate is self-signed and intended for testing purposes. For production use, consider using a valid SSL certificate from a Certificate Authority.


