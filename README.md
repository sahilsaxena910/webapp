Terraform Module: Deploys a simple web app using AWS VPC with Load Balancer
This Terraform module sets up an AWS Virtual Private Cloud (VPC) with public and private subnets, an Application Load Balancer (ALB), and associated resources. It also includes Auto Scaling for EC2 instances and CloudWatch Alarms for monitoring.

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