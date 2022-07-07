### This is Variable which we have Defined ####################
variable "region" {
  default = "us-east-2"
}
variable "ami_id" {
  default = "ami-02d1e544b84bf7502"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "az_zone" {
  default = "us-east-2a"
}

variable "vpc_cidr" {
    default = "172.16.0.0/16"
  
}

variable "pub_subnet_cidr" {
  default = "172.16.1.0/24"
}

variable "priv_subnet_cidr" {
  default = "172.16.2.0/24"
}
variable "route" {
  default = "0.0.0.0/0"
}


## it will create pemkey for instances

variable "key_name" {
  default = "ec2Key-dev"      # if we keep default blank it will ask for a value when we execute terraform apply
}
