resource "aws_vpc" "myvpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = var.instance_tenancy

  tags = {
    Name = var.environment_name
  }
}

resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.cidr_block_pub
  availability_zone = var.availability_zone_pubsub

  tags = {
    Name = var.sub_pub
  }
}

resource "aws_subnet" "pvtsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.cidr_block_prvt
  availability_zone = var.availability_zone_prvtsub

  tags = {
    Name = var.sub_prvt
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = var.igw
  }
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
      cidr_block = var.cidr_pubrt
      gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = var.pubrt
  }
}

resource "aws_route_table_association" "pubsubassociate" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_eip" "myeip" {
  vpc      = true

tags = {
    Name = var.eip
  }
}

resource "aws_nat_gateway" "mynat" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = var.nat_gateway
  }
}

resource "aws_route_table" "pvtrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
      cidr_block = var.cidr_prvtrt
      gateway_id = aws_nat_gateway.mynat.id
  }

  tags = {
    Name = var.prvtrt
  }
}

resource "aws_route_table_association" "pvtsubassociate" {
  subnet_id      = aws_subnet.pvtsub.id
  route_table_id = aws_route_table.pvtrt.id
}

resource "aws_security_group" "allow_all" {
  name        = var.pubsecuritygrp
  description = var.pubsgdescription
  vpc_id      = aws_vpc.myvpc.id

ingress {
      description      = var.ingressdescription_a
      from_port        = var.ingressfromport_a
      to_port          = var.ingresstoport_a
      protocol         = var.ingressprotocol_a
      cidr_blocks      = ["0.0.0.0/0"]
  }
ingress {
      description      = var.ingressdescription_b
      from_port        = var.ingressfromport_b
      to_port          = var.ingresstoport_b
      protocol         = var.ingressprotocol_b
      cidr_blocks      = ["0.0.0.0/0"]
  }
egress {
      description      = var.egressdescription
      from_port        = var.egressfromport
      to_port          = var.egresstoport
      protocol         = var.egressprotocol
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
  }
 tags = {
    Name = var.pubsg
  }
}


resource "aws_instance" "pubec2" {
  ami                         =  var.pub_ami
  count                       =   var.pubec2count
  instance_type               =  var.pub_instance_type
  subnet_id                   =  aws_subnet.pubsub.id
  key_name                    =  var.pub_key_name
  associate_public_ip_address =  var.associate_pub
  availability_zone           =  var.availability_zone_pubec2
  vpc_security_group_ids      =  [aws_security_group.allow_all.id]
  tags = {
    Name = var.pubec2
  }
}

resource "aws_instance" "pvtec2" {
  ami                         =  var.prvt_ami
  count                       =   var.prvtec2count
  instance_type               =  var.prvt_instance_type
  subnet_id                   =  aws_subnet.pvtsub.id
  key_name                    =  var.prvt_key_name
  availability_zone           =  var.availability_zone_prvtec2
  vpc_security_group_ids      =  [aws_security_group.allow_all.id]

  tags = {
    Name = var.pvrtec2
  }
}

