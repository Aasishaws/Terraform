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

  tags = {
    Name = var.sub_pub
  }
}

resource "aws_subnet" "pvtsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.cidr_block_prvt

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

resource "aws_route_table" "pvtrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
      cidr_block = var.cidr_prvtrt
      gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = var.prvtrt
  }
}

resource "aws_route_table_association" "pvtsubassociate" {
  subnet_id      = aws_subnet.pvtsub.id
  route_table_id = aws_route_table.pvtrt.id
}
resource "aws_instance" "pubec2" {
  ami                         =  var.pub_ami
  instance_type               =  var.pub_instance_type
  subnet_id                   =  aws_subnet.pubsub.id
  key_name                    =  var.pub_key_name
  associate_public_ip_address =  var.associate_pub

  tags = {
    Name = var.pubec2
  }
}

resource "aws_instance" "pvtec2" {
  ami                         =  var.prvt_ami
  instance_type               =  var.prvt_instance_type
  subnet_id                   =  aws_subnet.pvtsub.id
  key_name                    =  var.prvt_key_name


  tags = {
    Name = var.pvrtec2
  }
}
