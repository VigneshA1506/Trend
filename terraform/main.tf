terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "trend_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "trend-vpc"
  }
}

resource "aws_subnet" "trend_subnet" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "trend-subnet"
  }
}

resource "aws_internet_gateway" "trend_igw" {
  vpc_id = aws_vpc.trend_vpc.id

  tags = {
    Name = "trend-igw"
  }
}

resource "aws_route_table" "trend_route_table" {
  vpc_id = aws_vpc.trend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.trend_igw.id
  }

  tags = {
    Name = "trend-route-table"
  }
}

resource "aws_route_table_association" "trend_subnet_association" {
  subnet_id      = aws_subnet.trend_subnet.id
  route_table_id = aws_route_table.trend_route_table.id
}

resource "aws_security_group" "trend_sg" {
  name        = "trend-sg"
  description = "Security group for Trend Jenkins EC2"
  vpc_id      = aws_vpc.trend_vpc.id

  # SSH - replace YOUR_PUBLIC_IP with your own public IP
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.139.35.58/32"]
  }

  # Jenkins
  # Required for browser access and GitHub webhook
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS - required for Jenkins/Docker/GitHub/AWS communication
  egress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP - required for package downloads and repositories
  egress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS - VPC DNS resolver
  egress {
    description = "DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.2/32"]
  }

  egress {
    description = "DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.2/32"]
  }

  tags = {
    Name = "trend-sg"
  }
}

resource "aws_instance" "trend_ec2" {
  ami           = "ami-0d15e9052c94acb75"
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.trend_subnet.id
  vpc_security_group_ids      = [aws_security_group.trend_sg.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.trend_ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
 
              # Update system
              dnf update -y
 
              # Install Java, required by Jenkins
              dnf install -y fontconfig java-21-amazon-corretto wget
 
              # Install Docker
              dnf install -y docker
 
              # Start and enable Docker
              systemctl enable docker
              systemctl start docker
 
              # Allow ec2-user and Jenkins to use Docker
              usermod -aG docker ec2-user
 
              # Install Jenkins repository
              wget -O /etc/yum.repos.d/jenkins.repo \
                https://pkg.jenkins.io/rpm-stable/jenkins.repo
 
              # Import Jenkins signing key
              rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key
 
              # Install Jenkins
              dnf install -y jenkins
 
              # Allow Jenkins to use Docker
              usermod -aG docker jenkins
 
              # Start and enable Jenkins
              systemctl enable jenkins
              systemctl start jenkins
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "trend-ec2"
  }
}

resource "aws_iam_role" "trend_ec2_jenkins_role" {
  name = "trend-ec2-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "trend-ec2-jenkins-role"
  }
}

resource "aws_iam_role_policy" "trend_eks_access" {
  name = "trend-eks-access"
  role = aws_iam_role.trend_ec2_jenkins_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "eks:DescribeCluster"
        ]

        Resource = "arn:aws:eks:ap-south-1:*:cluster/trend-eks-cluster"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "trend_ec2_profile" {
  name = "trend-ec2-jenkins-profile"
  role = aws_iam_role.trend_ec2_jenkins_role.name
}