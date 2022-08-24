provider "aws" {
    region = "us-west-1"
    access_key = "AKIAZJ4Y6W6N2W3UPA47"
    secret_key = "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"
}

# 1. Create VPC 

resource "aws_vpc" "siec" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "siec"
  }
}

# 2. Create Internet Gateway

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.siec.id

  tags = {
    Name = "InternetGateway"
  }
}

# 3. Create custom route table

resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.siec.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }

  tags = {
    Name = "RouteTable"
  }
}

# 4. Create a subnet
#
#resource "aws_subnet" "subnet1" {
# vpc_id     = aws_vpc.siec.id
# #cidr_block = "10.0.1.0/24"
# #availability_zone = "us-west-1a"
#
#  #tags = {
#    Name = "subnet1"
#  }
#}

#4.1 subnet 2

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.siec.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-1b"

  tags = {
    Name = "subnet2"
  }
}

#4.2 subnet 3

resource "aws_subnet" "subnet3" {
  vpc_id     = aws_vpc.siec.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-1c"

  tags = {
    Name = "subnet3"
  }
}

# 5. Assosiate subnet with route table
#
#resource "aws_route_table_association" "a" {
#  subnet_id      = aws_subnet.subnet1.id
#  route_table_id = aws_route_table.routetable.id
#}

#5.2

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.routetable.id
}

#5.3

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.routetable.id
}

# 6. Create Security Group to allow ports

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow  inbound traffic"
  vpc_id      = aws_vpc.siec.id



   ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_traffic"
  }
}

# 7. Create a network interface with an ip in the subnet created in step 4

#resource "aws_network_interface" "nic-prod1" {
#  subnet_id       = aws_subnet.subnet1.id
#  private_ips     = ["10.0.1.50"]
#  security_groups = [aws_security_group.allow_traffic.id]#
#
#}

# 7.2

resource "aws_network_interface" "nic-prod2" {
  subnet_id       = aws_subnet.subnet2.id
  private_ips     = ["10.0.2.50"]
  security_groups = [aws_security_group.allow_traffic.id]

}

# 7.3

resource "aws_network_interface" "nic-prod3" {
  subnet_id       = aws_subnet.subnet3.id
  private_ips     = ["10.0.3.50"]
  security_groups = [aws_security_group.allow_traffic.id]

}

# 8. Assign an elastic ip to the network interface created in step 7\

#resource "aws_eip" "one" {
#  vpc                       = true
# network_interface         = aws_network_interface.nic-prod1.id
#  associate_with_private_ip = "10.0.1.50"
#  depends_on = [aws_internet_gateway.InternetGateway]
#}


#8.2

resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = aws_network_interface.nic-prod2.id
  associate_with_private_ip = "10.0.2.50"
  depends_on = [aws_internet_gateway.InternetGateway]
}

#8.3

resource "aws_eip" "three" {
  vpc                       = true
  network_interface         = aws_network_interface.nic-prod3.id
  associate_with_private_ip = "10.0.3.50"
  depends_on = [aws_internet_gateway.InternetGateway]
}
# 9. Create a serrver with appache(Optional)

#resource "aws_instance" "zad2_1" {
# ami           = "ami-0d75513e7706cf2d9" 
#  instance_type = "t2.micro"
#  availability_zone = "us-west-1a"
#  key_name = "main2"
#
#  network_interface {
#     network_interface_id = aws_network_interface.nic-prod1.id
#    device_index         = 0
#  }
#user_data = <<-EOF
#               #!/bin/bash
#                 sudo apt update -y
#                 sudo apt install apache2 -y
#                 sudo systemctl start apache2
#                 sudo bash -c 'echo your very first web server > /var/www/html/index.html'
#                 EOF
#   tags = {
#     Name = "web-server"
#  }
#}

#9.2

resource "aws_instance" "zad2_2" {
  ami           = "ami-085284d24fe829cd0" 
  instance_type = "t2.micro"
  availability_zone = "us-west-1b"
  key_name = "mainc"

  network_interface {
     network_interface_id = aws_network_interface.nic-prod2.id
    device_index         = 0
  }
user_data = <<-EOF
               #!/bin/bash
                 sudo apt update -y
                 sudo apt install apache2 -y
                 sudo systemctl start apache2
                 sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                 EOF
   tags = {
     Name = "web-server"
  }
}

#9.3

resource "aws_instance" "zad2_3" {
  ami           = "ami-085284d24fe829cd0" 
  instance_type = "t2.micro"
  availability_zone = "us-west-1c"
  key_name = "mainc"

  network_interface {
     network_interface_id = aws_network_interface.nic-prod3.id
    device_index         = 0
  }
user_data = <<-EOF
               #!/bin/bash
                 sudo apt update -y
                 sudo apt install apache2 -y
                 sudo systemctl start apache2
                 sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                 EOF
   tags = {
     Name = "web-server"
  }
}