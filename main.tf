provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source        = "/mnt/terraform-module/modules/ec2"
  ami           = "ami-04aa00acb1165b32a"
  instance_type = "t2.micro"
  name          = "EC2-Module"
}

