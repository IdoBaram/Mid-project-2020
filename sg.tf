data "http" "public_ip" {
   url = "https://api.ipify.org"
}

locals {
  my_ip = "${data.http.public_ip.body}/32"
}

resource "aws_security_group" "ansible-sg" {
 name        = "ansible-sg"
 description = "security group for ansible servers"
 vpc_id      = aws_vpc.vpc1.id
  egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = [var.egress_cidr_blocks]
 }

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = [local.my_ip]
    }
  }
  tags = {
    Name = "ansible-sg"
  }
}

resource "aws_security_group" "jenkins-sg" {
  name = "jenkins-sg"
  vpc_id      = aws_vpc.vpc1.id
  description = "Allow Jenkins inbound traffic"

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [var.egress_cidr_blocks]
 }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [local.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip,"10.1.0.0/16"]
  }

  ingress {
    from_port   = 2375
    to_port     = 2375
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_security_group" "k8s" {
  name_prefix = "k8s"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      local.my_ip
    ]
  }
   tags = {
    Name = "k8s-sg"
  }
}

resource "aws_security_group" "consul-sg" {
  name        = "opsschool-consul"
  vpc_id      = aws_vpc.vpc1.id
  description = "Allow ssh & consul inbound traffic"
  tags = {
    Name      = "opsschool_consul_sg"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
    description = "Allow ssh from the world"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
    description = "Allow Apache from the world"
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
    description = "Allow consul UI access from the world"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.egress_cidr_blocks]
    description = "Allow all outside security group"
  }
}