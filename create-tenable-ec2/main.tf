module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "tenable_scanner"

  instance_type          = "c6i.xlarge"
  key_name               = "tenable_kp"
  monitoring             = true
  vpc_security_group_ids = ["sg-086ed9f544a38b93a"]
  subnet_id              = "subnet-091a2af3d6b0b492f"
  ami                    = var.tenable_image_id
  associate_public_ip_address = true

  tags = {
    owner   = "team2"
    Environment = "nonprod"
  }
}
