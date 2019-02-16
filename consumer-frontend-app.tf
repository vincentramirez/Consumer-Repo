variable "number_of_instances" {
  description = "Number of instances to create and attach to Consumer ELB"
  default     = 1
}

variable "name" {
  description = "The name of the app deployed"
  default = "Consumer-FrontEnd-App"
}

module "elb" {
  source  = "app.terraform.io/aharness-org/consumer-elb/aws"
  version = "1.9"
  name = "${var.name}-elb"
  
  # ELB attachments
  number_of_instances = "${var.number_of_instances}"
  instances           = ["${module.ec2_instances.id}"]
}
  
module "ec2_instances" {
  source = "app.terraform.io/aharness-org/consumer-ec2-instance/aws"
  version = "1.4"
  name                        = "${var.name}-ec2"
  instance_count = "${var.number_of_instances}"
}
