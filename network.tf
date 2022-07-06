 
# Creating VPC,Subnets,routetables Gateway, Natgatway and subnet association Etc.....
resource "aws_vpc" "awslab-vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "awslab-vpc"
  }
}
# Creating Public Subnet in VPC

resource "aws_subnet" "awslab-subnet-public" {
  vpc_id                  = aws_vpc.awslab-vpc.id
  cidr_block              = var.pub_subnet_cidr
  availability_zone = var.az_zone
 map_public_ip_on_launch = "true"
  depends_on = [aws_vpc.awslab-vpc]
  tags = {
    Name = "awslab-subnet-public"
  }
}

resource "aws_subnet" "awslab-subnet-private" {
    
  vpc_id                  = aws_vpc.awslab-vpc.id
  cidr_block              = var.priv_subnet_cidr
  map_public_ip_on_launch = "false"
  availability_zone = var.az_zone  
  depends_on = [aws_vpc.awslab-vpc]
  tags = { 
        Name = "DB_subnet"
    }
  }

  # Creating Route Associations public subnets
resource "aws_route_table_association" "awslab-rt-internet" {
  subnet_id      = aws_subnet.awslab-subnet-public.id
  route_table_id = aws_route_table.routing_table.id
}
# It will create Itnetnetgateway
resource "aws_internet_gateway" "awslab-vpc-gw" {
  vpc_id = aws_vpc.awslab-vpc.id

  tags = {
    Name = "awslab-vpc-gw"
  #  depends_on = [awslab-vpc]
  }
}
##It will create EIP
  resource "aws_eip" "elastic_ip" {
   vpc      = true
}


# Creating Route Tables for Internet gateway
resource "aws_route_table" "routing_table" {
  vpc_id = aws_vpc.awslab-vpc.id

  route {
#    cidr_block = "0.0.0.0/0"
    cidr_block =  var.route
    gateway_id = aws_internet_gateway.awslab-vpc-gw.id
  }

  tags = {
    Name = "public_table"
  }
}



# NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.awslab-subnet-public.id

  tags = {
    Name = "awslab-gateway"
  }
}

## Nat route Table 
resource "aws_route_table" "NAT_route_table" {
  

  vpc_id = aws_vpc.awslab-vpc.id

  route {
    #cidr_block = "0.0.0.0/0"
    cidr_block = var.route
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Awslab-NAT-route-table"
  }
}

## Routing Table association 
resource "aws_route_table_association" "associate_routetable_to_private_subnet" {
  
  subnet_id      = aws_subnet.awslab-subnet-private.id
  route_table_id = aws_route_table.NAT_route_table.id
}

#Create a security group-public

resource "aws_security_group" "awslab-vpc-sg" {

name = "awslab-vpc-sg"

description = "Allow Web inbound traffic"

vpc_id = aws_vpc.awslab-vpc.id



ingress {

protocol = "tcp"

from_port = 80

to_port = 80

cidr_blocks = ["0.0.0.0/0"]

}



ingress {

protocol = "tcp"

from_port = 22

to_port = 22

cidr_blocks = ["0.0.0.0/0"]

}

ingress {

protocol = "tcp"

from_port = 443

to_port = 443

cidr_blocks = ["0.0.0.0/0"]

}
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Allowing a security group form DB server
resource "aws_security_group" "awslab-vpc-db_sg" {

name = "awslab-vpc-db_sg"

description = "Allow Web inbound traffic"
vpc_id = aws_vpc.awslab-vpc.id




ingress {

protocol = "tcp"

from_port = 22

to_port = 22

cidr_blocks = ["172.16.1.0/24"]

}

ingress {

protocol = "TCP"

from_port = 3110

to_port = 3110

cidr_blocks = ["172.16.1.0/24"]

}


ingress {

protocol = "icmp"

from_port = -1

to_port = -1

cidr_blocks = ["172.16.1.0/24"]

}

tags = {
    Name = "awslab-vpc-sg"
}


egress {

protocol = "-1"

from_port = 0

to_port = 0

cidr_blocks = ["0.0.0.0/0"]

}

}
