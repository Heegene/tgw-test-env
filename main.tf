
module "ireland_tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name        = "ireland-tgw"
  description = "My TGW shared with several other AWS accounts"
  enable_auto_accept_shared_attachments = true
  share_tgw = false
  amazon_side_asn = "64556"

  vpc_attachments = {
    vpc = {
      vpc_id       = module.ireland_legacy_vpc.vpc_id
      subnet_ids   = module.ireland_legacy_vpc.private_subnets
      dns_support  = true
      ipv6_support = true

      # tgw_routes = [
      #   {
      #     destination_cidr_block = "30.0.0.0/16"
      #   },
      #   {
      #     blackhole = true
      #     destination_cidr_block = "40.0.0.0/20"
      #   }
      # ]
    }
  }

  tags = {
    legacy = "true"
    env = "legacy"
  }
}

module "ireland_legacy_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "leagcy-vpc"
  cidr = "10.2.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["10.2.1.0/24", "10.2.2.0/24"]

  enable_ipv6                                    = false
  private_subnet_assign_ipv6_address_on_creation = false
  # private_subnet_ipv6_prefixes                   = [0, 1, 2]
  
  tags = {
    legacy = "true"
    env = "legacy"
  }
  
  }
  
  resource "aws_security_group" "ping" {
  name        = "legacy-sg"
  description = "Allow ping inbound traffic"
  vpc_id      = module.ireland_legacy_vpc.vpc_id

  ingress {
    description      = "ping"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "icmp"
  }
  }
  
  module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  subnet_id = module.ireland_legacy_vpc.private_subnets[0]
  name = "legacy-instance"

  ami                    = "ami-0ee415e1b8b71305f"
  instance_type          = "t2.micro"
  monitoring             = false
  vpc_security_group_ids = ["${aws_security_group.ping.id}"]
  #vpc_security_group_ids = []
  #subnet_id              = "subnet-eddcdzz4"
  iam_instance_profile  = "ec2_instance_profile_CloudWAN_Workshop"

  tags = {
    Terraform   = "true"
    Environment = "dev"
    env         = "legacy"
  }
}
