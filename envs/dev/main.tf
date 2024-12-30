############################# VPC #########################################
module "vpc" {
  source               = "../../modules/vpc"
  cidr_block           = "10.0.0.0/16"
  egress               = var.egress
  ingress              = var.ingress
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    Key   = "Name"
    Value = "dev-vpc"
  }
}

##################################### Elastic Load Balancer ##########################
module "elb" {
  source                     = "../../modules/elb"
  name                       = var.name
  load_balancer_type         = var.load_balancer_type
  internal                   = var.internal
  listener                   = var.listener
  vpc_id                     = module.vpc.webapp_vpc_id
  target_grp                 = var.target_grp
  security_group_ids         = [module.vpc.dev_elb_sg]
  asg_id                     = module.asg.asg_id
  subnet_ids                 = module.vpc.webapp_public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  tags = {
    Key   = "Name"
    Value = "dev-elb"
  }
}

##################################### Auto Scaling Group #################################
module "asg" {
  source             = "../../modules/asg"
  desired_capacity   = var.desired_capacity
  subnet_ids         = module.vpc.webapp_private_subnet_ids
  max_size           = var.max_size
  health_check_type  = var.health_check_type
  ami_id             = data.aws_ami.ubuntu.id
  security_group_ids = [module.vpc.webapp_sg_ids]
  instance_type      = var.instance_type
  min_size           = var.min_size
  user_data          = base64encode(file("user_data.sh"))
}

