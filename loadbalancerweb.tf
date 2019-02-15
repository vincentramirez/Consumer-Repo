variable "number_of_instances" {
  description = "Number of instances to create and attach to Consumer ELB"
  default     = 2
}

module "elb" {
  source = "app.terraform.io/aharness-org/elb/aws"

  name = "consumer-web-elb"

  subnets         = ["${data.terraform_remote_state.network.research_subnet_id}"]
  security_groups = ["${data.terraform_remote_state.network.default_security_group_id}"]
  internal        = true

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
    {
      instance_port     = "8080"
      instance_protocol = "HTTP"
      lb_port           = "8080"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = [
    {
      target              = "HTTP:80/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    },
  ]
  
  tags = {
    Owner       = "user"
    Environment = "dev"
  }
  
  # ELB attachments
  number_of_instances = "${var.number_of_instances}"
  instances           = ["${module.ec2_instances.id}"]
}

################
# EC2 instances
################
module "ec2_instances" {
  source = "app.terraform.io/aharness-org/ec2-instance/aws"

  instance_count = "${var.number_of_instances}"

  name                        = "consumer-web-app"
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${data.terraform_remote_state.network.default_security_group_id}"]
  subnet_id                   = "${data.terraform_remote_state.network.research_subnet_id}"
  associate_public_ip_address = true
}
