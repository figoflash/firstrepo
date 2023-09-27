module "canton_install-baseline-tools_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "canton_install-baseline-tools component"
  name              = "canton_install-baseline-tools-component"
  commands          = ["(apt-get update; apt-get -y install ca-certificates curl gnupg; install -m 0755 -d /etc/apt/keyrings; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null; chmod a+r /etc/apt/keyrings/docker.gpg; apt-get update; apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; apt-get -y install vim; apt-get -y install jq; apt-get -y install git;)"]
#  tags              = local.tags
}


module "canton_install-psql-client_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "canton_install-psql-client component"
  name              = "canton_install-psql-client-component"
  commands          = ["(apt-get update; apt-get -y install postgresql-client;)"]
#  tags              = local.tags
}


module "canton_devsec-os-hardening_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "canton_install_devsec-os-hardening component"
  name              = "canton_install_devsec-os-hardening-component"
  commands          = ["(apt-get update; apt-get -y install ansible; ansible-galaxy collection install devsec.hardening; curl https://omnitruck.chef.io/install.sh | bash -s -- -P inspec; apt-get -y install git; git clone https://github.com/figoflash/firstrepo; ansible-playbook -i localhost firstrepo/dev-sec-playbook.yml; git clone https://github.com/dev-sec/linux-baseline; inspec exec linux-baseline > /var/tmp/inspec_exec_linux-baseline.out)"]
#  tags              = local.tags
}



module "canton_recipe" {
  source = "rhythmictech/imagebuilder-recipe/aws"

  name = "canton-recipe"

  working_directory = "/tmp"

  description    = "canton recipe"
  parent_image   = "arn:aws:imagebuilder:ap-east-1:aws:image/minimal-ubuntu-2204-lts-jammy-a060/x.x.x"
  recipe_version = "1.2.0"
  update         = false

  component_arns = [
    "arn:aws:imagebuilder:ap-east-1:aws:component/amazon-cloudwatch-agent-linux/1.0.1/1",    
    "arn:aws:imagebuilder:ap-east-1:aws:component/simple-boot-test-linux/1.0.0/1",
    "arn:aws:imagebuilder:ap-east-1:aws:component/update-linux/1.0.2/1",
    module.canton_install-baseline-tools_component.component_arn,
    module.canton_install-psql-client_component.component_arn,
#    module.canton_install-minimal-desktop_component.component_arn,
#    module.canton_devsec-os-hardening_component.component_arn
  ]
}

module "canton_pipeline" {
  source = "rhythmictech/imagebuilder-pipeline/aws"

  name = "canton-pipeline"

#  subnet = "subnet-029609d099e7e8548"
  instance_types = ["t3.micro"]
#  security_group_ids = ["sg-07f2889d86b5e50b3"]

  description = "canton pipeline"
  public      = false
  terminate_on_failure = false
  image_recipe_arn = module.canton_recipe.recipe_arn
  regions = [
  #  "us-east-1",
  #  "us-east-2"
    "ap-east-1"
  ]
  custom_distribution_configs = [
    {
      region = "ap-east-1",
      ami_distribution_configuration = {
        name = "canton-ami-{{ imagebuilder:buildDate }}"
        launch_permission = {
          user_ids = ["333347968576", "558294673728", "173633673455", "703375429053", "793719249882", "480546907858", "678757538058"]
        }
      }
      launch_template_configuration = {
        launch_template_id = aws_launch_template.lt-canton.id
      }
    },
    {
      region = "eu-west-2",
      ami_distribution_configuration = {
        name = "canton-ami-{{ imagebuilder:buildDate }}"
        launch_permission = {
          user_ids = ["333347968576", "558294673728", "173633673455", "703375429053", "793719249882", "480546907858", "678757538058"]
        }
      }
      # pre-created in eu-west-2
      launch_template_configuration = {
        launch_template_id = "lt-028fef9a50e1d866f"
      }

    }
  ]
}


resource "aws_launch_template" "lt-canton" {
  name = "canton-launchtemplate2"

  instance_type = "t3.micro"

  placement {
    availability_zone = "ap-east-1a"
  }
}
