terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ansible_server" {
  count                       = 1
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.public.*.id, 0)
  vpc_security_group_ids      = [aws_security_group.ansible-sg.id]
  key_name                    = aws_key_pair.mid_project_key.key_name
  user_data                   = "${file("ansible.sh")}"

  provisioner "file" {
  source      = "./mid_project_key.pem"
  destination = "/home/ubuntu/mid_project_key.pem"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${tls_private_key.mid_project_key.private_key_pem}"
    host        = self.public_ip
  }
  } 

  tags = {
    Name          = "Ansible Server"
    consul_server = true
  }
}


resource "aws_instance" "Consul_Server" {
    count                  = 3
    instance_type          = var.instance_type
    ami          	         = data.aws_ami.ubuntu.id
    vpc_security_group_ids = [aws_security_group.consul-sg.id]
    subnet_id              = element(aws_subnet.public.*.id, count.index)
    key_name               = aws_key_pair.mid_project_key.key_name
    iam_instance_profile   = "${aws_iam_instance_profile.consul_join.name}"
    user_data              = "${file("consul-server.sh")}"

  tags = {
    Name          = "Consul Server ${count.index+1}"
    Purpose       = "OpsSchool training"
    consul_server = true  
  }
}