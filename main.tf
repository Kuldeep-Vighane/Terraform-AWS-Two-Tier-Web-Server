resource "aws_vpc" "myvpc" {
  cidr_block       = var.CIDRblockVPC
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.CIDRblockSub1
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.CIDRblockSub2
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true


  tags = {
    Name = "sub2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = var.CIDRblockRT
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "RT"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}


# Security Group
resource "aws_security_group" "websg" {
  name        = "WebSG"
  description = "Allow SSH and HTTP inbound, all outbound"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "WebSG"
  }
}

# Ingress rule for SSH (port 22)
resource "aws_vpc_security_group_ingress_rule" "ssh_ingress" {
  security_group_id = aws_security_group.websg.id
  cidr_ipv4         = "0.0.0.0/0" # In production, restrict to your IP!
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Ingress rule for HTTP (port 80)
resource "aws_vpc_security_group_ingress_rule" "http_ingress" {
  security_group_id = aws_security_group.websg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Egress rule for all outbound traffic (IPv4)
resource "aws_vpc_security_group_egress_rule" "all_out_ipv4" {
  security_group_id = aws_security_group.websg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all protocols
}

resource "aws_s3_bucket" "mys3bucket" {
  bucket = "kuldeeepterraform20250920"
}

# Ownership controls
resource "aws_s3_bucket_ownership_controls" "mybucket" {
  bucket = aws_s3_bucket.mys3bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Public access block (allowing public)
resource "aws_s3_bucket_public_access_block" "mybucket" {
  bucket = aws_s3_bucket.mys3bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Make bucket public
resource "aws_s3_bucket_acl" "mybucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.mybucket,
    aws_s3_bucket_public_access_block.mybucket,
  ]

  bucket = aws_s3_bucket.mys3bucket.id
  acl    = "public-read"
}


# EC2 Instance
resource "aws_instance" "my_ec2A" {
  ami                    = "ami-02d26659fd82cf299"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.websg.id]
  user_data = file("Startshell.sh")

  tags = {
    Name = "MyEC2InstanceA"
  }
}

resource "aws_instance" "my_ec2B" {
  ami                    = "ami-02d26659fd82cf299"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_security_group.websg.id]
  user_data = file("Startshell.sh")

  tags = {
    Name = "MyEC2InstanceB"
  }
}

resource "aws_lb" "myLB" {
  name               = "myLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.websg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "WebLB"
  }
}


resource "aws_lb_target_group" "tg" {
  name     = "MyTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "TGattach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.my_ec2A.id
  port = 80
}

resource "aws_lb_target_group_attachment" "TGattach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.my_ec2B.id
  port = 80
}

resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.myLB.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type = "forward"
  }
}

output "LBDNS" {
  value = aws_lb.myLB.dns_name
}