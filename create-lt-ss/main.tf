resource "aws_launch_template" "sles15-launch-template" {
  name = "sles15-launch-template"
  image_id = "ami-12345678901234567"
  #image_id = data.aws_ssm_parameter.sles15-ami.value
  tags = {
    Name = "test"
  }
}

resource "aws_launch_template" "jumphost-launch-template" {
  name = "jumphost-launch-template"
  image_id = "ami-12345678901234567"
  tags = {
    Name = "test"
  }
}

resource "aws_launch_template" "win2022-launch-template" {
  name = "win2022-launch-template"
  image_id = "ami-12345678901234567"
  tags = {
    Name = "test"
  }
}

resource "aws_launch_template" "canton-launch-template" {
  name = "canton-launch-template"
  image_id = "ami-12345678901234567"
  tags = {
    Name = "test"
  }
}

resource "aws_launch_template" "sles15-launch-template-london" {
  provider = aws.london
  name = "sles15-launch-template-london"
  image_id = "ami-12345678901234567"
  tags = {
    Name = "test"
  }
}

resource "aws_launch_template" "jumphost-launch-template-london" {
  provider = aws.london
  name = "jumphost-launch-template-london"
  image_id = "ami-12345678901234567"
  tags = {
    Name = "test"
  }
}

resource "aws_launch_template" "win2022-launch-template-london" {
  provider = aws.london
  name = "win2022-launch-template-london"
  image_id = "ami-12345678901234567"
  tags = {
    Name = "test"
  }
}

resource "aws_launch_template" "canton-launch-template-london" {
  provider = aws.london
  name = "canton-launch-template-london"
  image_id = "ami-12345678901234567"
  tags = {
    Name = "test"
  }
}
