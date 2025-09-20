AWS Two-Tier Web Server with Application Load Balancer (Terraform + Shell Script)

This project provisions a two-tier web server architecture on AWS using Terraform and a custom user-data shell script.
It deploys two EC2 instances running Apache web servers, places them behind an Application Load Balancer (ALB), and serves a dynamically generated webpage showing EC2 instance metadata.

📌 Features

Terraform-based IaC: Fully automated VPC, Subnets, Security Groups, ALB, and EC2 instances.

Ubuntu 24.04 AMI with Apache2 installed and configured automatically via user_data.

IMDSv2 Metadata Fetching: Securely retrieves instance metadata (ID, Type, AZ, IPs, Region).

Custom Web Page: HTML + CSS displaying server details and timestamp.

Highly Available: Instances deployed across multiple Availability Zones (ap-south-1a & ap-south-1b).

Load Balancer (ALB) for distributing traffic and automatic health checks.

📂 Project Structure
terraform_aws_two_tier/
├── main.tf              # Main Terraform configuration (VPC, Subnets, IGW, Route Tables, SGs, EC2, ALB)
├── variables.tf         # Input variables (CIDR blocks, etc.)
├── outputs.tf           # Outputs (ALB DNS)
├── Startshell.sh        # User-data script (installs Apache & creates metadata HTML page)

⚙️ Infrastructure Overview

VPC: Custom VPC with public subnets in multiple AZs.

Subnets:

Subnet A → ap-south-1a

Subnet B → ap-south-1b

Internet Gateway & Route Tables: Enables internet access for public subnets.

Security Group: Allows inbound SSH (22) & HTTP (80).

EC2 Instances: Ubuntu 24.04, Apache2, auto-configured HTML page.

Application Load Balancer: Distributes requests across EC2 instances, performs health checks.

🖥️ Web Page Preview

Each EC2 instance serves a page with:

Instance ID

Instance Type

Availability Zone

Region

Private & Public IP

Timestamp

Styled with a gradient background and info card for professional look.

🚀 Deployment Steps

Clone Repository

git clone https://github.com/your-repo/aws-two-tier-webserver.git
cd aws-two-tier-webserver


Initialize Terraform

terraform init


Validate Configuration

terraform validate


Preview Plan

terraform plan


Apply Infrastructure

terraform apply -auto-approve


Get Load Balancer DNS

terraform output LBDNS


Test in Browser
Paste the DNS URL in your browser to access the web server.

🔧 Technologies Used

Terraform (IaC for AWS)

AWS EC2, VPC, ALB, Security Groups, Subnets

Ubuntu 24.04

Apache2 Web Server

Shell Scripting (IMDSv2 Metadata fetching & HTML generation)

📖 Future Improvements

Add hit counter to track number of requests per server (A1, B1, A2, B2…).

Enable HTTPS with ACM SSL certificate.

Configure Auto Scaling Group (ASG) for better scalability.

Store logs in CloudWatch for monitoring.

📝 Author

Kuldeep Vighane – Cloud Engineer
📧 Contact: nishupvighane@gmail.com
🔗 GitHub: Kuldeep-Vighane
