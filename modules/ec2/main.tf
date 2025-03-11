resource "aws_instance" "qa" {
  ami           = var.ami
  instance_type = var.instance_type
  
  tags = {
    Name = var.name
  }
}

