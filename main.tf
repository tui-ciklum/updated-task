###Deploying web and Db instances, keys and IP outputs############### 
resource "aws_instance" "Webserver" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id      = aws_subnet.awslab-subnet-public.id
  vpc_security_group_ids = [aws_security_group.awslab-vpc-sg.id]
  associate_public_ip_address = true
  availability_zone = var.az_zone
  key_name = var.key_name
   user_data = file("httpd.sh")

  tags = {
    Name = "Webserver"
    Owner = "TUI"
    customer = "TUI"
  }
  provisioner "local-exec" {
  command = "chmod 400 /home/ec2-user/task/ec2Key-dev.pem"
}
 
}

# this will create a key with RSA algorithm with 4096 rsa bits
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# this resource will create a key pair using above private key
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh

   depends_on = [tls_private_key.private_key]
}

# this resource will save the private key at our specified path.
resource "local_file" "saveKey" {
  content = tls_private_key.private_key.private_key_pem
  filename = "${var.key_name}.pem"
  
   
}

resource "aws_instance" "db-server" {
  depends_on = [aws_route_table_association.associate_routetable_to_private_subnet]
  #ami = data.aws_ami.amzon.id
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id      = aws_subnet.awslab-subnet-private.id
  availability_zone = var.az_zone
  vpc_security_group_ids = [aws_security_group.awslab-vpc-db_sg.id]
  associate_public_ip_address = false
  key_name = var.key_name
  user_data = file("mariadb.sh")
  
  provisioner "local-exec" {
command = "scp -o StrictHostKeyChecking=no -i /home/ec2-user/task/ec2Key-dev.pem /home/ec2-user/task/ec2Key-dev.pem ec2-user@${aws_instance.Webserver.public_ip}:/home/ec2-user"
}

  tags = {
    Name = "db-server"
    Owner = "TUI"
    customer = "TUI"
  }
  
}

### Outputs of wenserver and db server Ips
output "DNS" {
  value = aws_instance.Webserver.public_dns
}

output "Webserver_ip" {
  value = aws_instance.Webserver.public_ip
}


output "db_server_ip" {
  value = aws_instance.db-server.private_ip
}
