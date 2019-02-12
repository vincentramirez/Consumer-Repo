data "terraform_remote_state" "network" {
  backend = "atlas"

  config {
    name = "${var.org}/${var.workspace_name}"
  }
}

provider "aws" {
  region = "${data.terraform_remote_state.network.region}"  
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id = "${data.terraform_remote_state.network.research_subnet_id}"

  tags {
    Name = "Research Instance"
  }
}
module "ec2_cluster" {
  source  = "app.terraform.io/aharness-org/ec2-instance/aws"
  version = "1.15.0"

  name                   = "my-consumer-cluster"
  instance_count         = 2

  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  monitoring             = true

  vpc_security_group_ids = ["${data.terraform_remote_state.network.default_security_group_id}"]
  subnet_id              = "${data.terraform_remote_state.network.research_subnet_id}"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}