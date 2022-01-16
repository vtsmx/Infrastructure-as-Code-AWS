# Data Source for getting Amazon Linux AMI
data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

/************************instances*****************************************/

# Resource for sub1
resource "aws_instance" "winccoa-sub1" {
  ami = data.aws_ami.amazon-2.id
  instance_type = "t3.micro"

  tags = {
    Name = "${var.winccoaSystemName}-sub1"
  }
  vpc_security_group_ids = [aws_security_group.ingress-all-ssh-winccoa.id, aws_security_group.ingress-all-http80.id, aws_security_group.ingress-all-https443.id, aws_security_group.ingress-dist-man.id]
  user_data = templatefile("${path.module}/winccoa-sub.tpl", { winccoaSysNum="2", winccoaSysName="sub1", winccoaSub1Ip="notused", winccoaSub2Ip="notused" } )
}

# Resource for sub2
resource "aws_instance" "winccoa-sub2" {
  ami = data.aws_ami.amazon-2.id
  instance_type = "t3.micro"

  tags = {
    Name = "${var.winccoaSystemName}-sub2"
  }
  vpc_security_group_ids = [aws_security_group.ingress-all-ssh-winccoa.id, aws_security_group.ingress-all-http80.id, aws_security_group.ingress-all-https443.id, aws_security_group.ingress-dist-man.id]
  user_data = templatefile("${path.module}/winccoa-sub.tpl", { winccoaSysNum="3", winccoaSysName="sub2", winccoaSub1Ip="notused", winccoaSub2Ip="notused" } )
}

# Resource for master
/*resource "aws_instance" "winccoa-master" {
  ami = data.aws_ami.amazon-2.id
  instance_type = "t3.micro"

  tags = {
    Name = "${var.winccoaSystemName}-master"
  }
  vpc_security_group_ids = [aws_security_group.ingress-all-ssh-winccoa.id, aws_security_group.ingress-all-http80.id, aws_security_group.ingress-all-https443.id, aws_security_group.ingress-dist-man.id]
  user_data = templatefile("${path.module}/winccoa-master.tpl", { winccoaSysNum="1", winccoaSysName="master${var.winccoaSystemIdx}", winccoaSub1Ip=aws_instance.winccoa-sub1.public_ip, winccoaSub2Ip=aws_instance.winccoa-sub2.public_ip } )
}*/

/************************SECURITY*****************************************/

resource "aws_security_group" "ingress-all-ssh-winccoa" {
  name = "${var.winccoaSystemName}-allow-all-ssh-winccoa"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress-all-http80" {
  name = "${var.winccoaSystemName}-allow-all-http80"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress-all-https443" {
  name = "${var.winccoaSystemName}-allow-all-https443"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress-dist-man" {
  name = "${var.winccoaSystemName}-ingress-dist-man"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 4777
    to_port = 4777
    protocol = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb_http" {
  name        = "${var.winccoaSystemName}-elb_http"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP through ELB Security Group"
  }
}