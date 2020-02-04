locals {
  jenkins_default_name = "jenkins"
}

resource "aws_instance" "jenkins_master" {
  count                       = 1
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.public.*.id, 1)
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  key_name                    = aws_key_pair.mid_project_key.key_name

  tags = {
    Name = "Jenkins Master"
    consul_server = true
  }
}

resource "aws_instance" "jenkins_agent" {
  ami                    = data.aws_ami.ubuntu.id
  count                  = length(var.availability_zone)
  subnet_id              = element(aws_subnet.private.*.id, count.index)
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mid_project_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  iam_instance_profile   = "mid_project_automation"
  user_data              = "${file("jenkins_slave.sh")}"
  
  tags = {
    Name = "Jenkins Agent ${count.index+1}"
    consul_server = true
  }
}