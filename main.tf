# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# 1. Create VPC
resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev-vpc.id

}

# 3. Create custom Route Table
resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "dev"
  }
}

# 4. Create a Subnet
resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "dev-subnet"
    }
}

# 5. Associate Subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.dev-route-table.id
}

# 6. Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.dev-vpc.id

  tags = {
    Name = "allow_web"
  }
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"        # semantically equivalent to all ports
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.allow_web.id

  description       = "HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  description       = "HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  description       = "SSH"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# 7. Create a network interface with an IP in the Subnet that was created in Step 4
resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# 8. Assign an Elastic IP (Public) to the network interface created in Step 7
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.gw ]
}

# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "web_server_instance" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "main-tf-key"

    network_interface {
        network_interface_id = aws_network_interface.web_server_nic.id
        device_index = 0
    }

    user_data = <<EOF
                #! /bin/bash
                sudo apt update
                sudo apt install -y apache2
                sudo systemctl start apache2
                sudo systemctl enable apache2
                sudo bash -c 'echo The page was created by the user data > /var/www/html/index.html'
                EOF

    tags = {
        Name = "web-server"
    }
}
