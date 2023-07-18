resource "aws_imagebuilder_component" "win2022-wpp-dev-tools" {
  data = yamlencode({
    phases = [{
      name = "build"
      steps = [{
        name: "install-wpp-dev",
        action: "ExecutePowerShell",
        inputs: {
            "commands": [
              "choco install google-chrome-x64 -y",
              "choco install firefox -y"
            ]
        }
        name      = "win2022-wpp-dev-tools"
        onFailure = "Continue"
      }]
    }]
    schemaVersion = 1.0
  })
  name     = "win2022-wpp-dev-tools"
  platform = "Windows"
  version  = "1.0.0"
}


resource "aws_imagebuilder_image_recipe" "win2022-recipe" {

  name         = "win2022-recipe"
  parent_image = "arn:aws:imagebuilder:ap-east-1:aws:image/windows-server-2022-english-full-base-x86/x.x.x"
  version      = "1.0.0"
  component {
    component_arn = "arn:aws:imagebuilder:ap-east-1:aws:component/amazon-cloudwatch-agent-windows/1.0.0/1"
  }
    component {
    component_arn = "arn:aws:imagebuilder:ap-east-1:aws:component/aws-cli-version-2-windows/1.0.0/1"
  }

  component {
    component_arn = "arn:aws:imagebuilder:ap-east-1:aws:component/stig-build-windows-low/2022.4.0/1"
  }

  component {
    component_arn = "arn:aws:imagebuilder:ap-east-1:aws:component/update-windows/1.0.1/1"
  }

  component {
    component_arn = "arn:aws:imagebuilder:ap-east-1:aws:component/reboot-windows/1.0.1/1"
  }

  component {
    component_arn = "arn:aws:imagebuilder:ap-east-1:aws:component/powershell-windows/7.2.10/1"
  }

  component {
    component_arn = "arn:aws:imagebuilder:ap-east-1:aws:component/putty/0.77.0/1"
  }
    
  component {
    component_arn = "arn:aws:imagebuilder:ap-east-1:aws:component/chocolatey/1.0.0/1"
  }
  
  component {
    component_arn = "arn:aws:imagebuilder:ap-east-1:aws:component/amazon-corretto-11-windows/1.0.0/1"
  }

  component {
    component_arn = aws_imagebuilder_component.win2022-wpp-dev-tools.arn
  }

}


module "test_pipeline" {
  source = "rhythmictech/imagebuilder-pipeline/aws"

  name = "win2022-pipeline"

  enabled = true
  #subnet = "subnet-029609d099e7e8548"
  #instance_types = ["t3.medium"]
  #security_group_ids = ["sg-07f2889d86b5e50b3"]

  description = "win2022 pipeline"
  public      = true
#  recipe_arn  = win2022-recipe.recipe_arn
#  image_recipe_arn = module.test_recipe.recipe_arn
  image_recipe_arn = aws_imagebuilder_image_recipe.win2022-recipe.arn
  regions = [
  #  "us-east-1",
  #  "us-east-2"
    "ap-east-1"
  #  "eu-west-2"
  ]
  custom_distribution_configs = [
    {
      region = "ap-east-1",
      ami_distribution_configuration = {
        name = "win2022-ami-{{ imagebuilder:buildDate }}"
        launch_permission = {
          user_ids = ["333347968576", "558294673728", "173633673455", "703375429053", "793719249882", "480546907858"]
        }
      }
      launch_template_configuration = {
        launch_template_id = aws_launch_template.lt-win2022.id
      }
    },
    {
      region = "eu-west-2",
      ami_distribution_configuration = {
        name = "win2022-ami-{{ imagebuilder:buildDate }}"
        launch_permission = {
          user_ids = ["333347968576", "558294673728", "173633673455", "703375429053", "793719249882", "480546907858"]
        }
      }
      # pre-created in eu-west-2
      launch_template_configuration = {
        launch_template_id = "lt-03541e63de8abb4d8"
      }

    }
  ]
}

resource "aws_launch_template" "lt-win2022" {
  name = "win2022-launchtemplate"

  instance_type = "t3.medium"

  placement {
    availability_zone = "ap-east-1a"
  }
}