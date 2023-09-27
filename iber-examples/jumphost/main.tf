module "jumphost_install-baseline-tools_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "jumphost_install-baseline-tools component"
  name              = "jumphost_install-baseline-tools-component"
  commands          = ["(apt-get update; apt-get -y install ca-certificates curl gnupg; install -m 0755 -d /etc/apt/keyrings; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null; chmod a+r /etc/apt/keyrings/docker.gpg; apt-get update; apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; apt-get -y install vim; apt-get -y install jq; apt-get -y install git)"]
#  tags              = local.tags
}

module "jumphost_install-cloudops-tools_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "jumphost_install-cloudops-tools component"
  name              = "jumphost_install-cloudops-tools-component"
  commands          = ["(apt-get update; snap install k9s; ln -s /snap/current/bin/k9s /usr/local/bin/k9s; curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null; apt-get install apt-transport-https --yes; echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main' | tee /etc/apt/sources.list.d/helm-stable-debian.list; apt-get update; apt-get -y install helm; cd /usr/local/bin; curl -LO https://dl.k8s.io/release/v1.27.2/bin/linux/amd64/kubectl; chmod a+x /usr/local/bin/kubectl; curl -sL https://istio.io/downloadIstioctl > installistioctl.sh ; chmod u+x ./installistioctl.sh ; ./installistioctl.sh; ln -s /root/.istioctl/bin/istioctl /usr/local/bin/istioctl; wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64; chmod a+x /usr/local/bin/yq)"]
#  tags              = local.tags
}

module "jumphost_install-minimal-desktop_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "jumphost_install-minimal-desktop component"
  name              = "jumphost_install-minimal-desktop-component"
  commands          = ["(apt-get update; DEBIAN_FRONTEND=noninteractive apt-get -y install ubuntu-desktop-minimal; DEBIAN_FRONTEND=noninteractive apt-get -y install lightdm; DEBIAN_FRONTEND=noninteractive apt-get -y install xrdp; apt-get -y install firefox)"]
#  tags              = local.tags
}

module "jumphost_devsec-os-hardening_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "jumphost_devsec-os-hardening component"
  name              = "jumphost_devsec-os-hardening-component"
  commands          = ["(apt-get update; apt-get -y install ansible; ansible-galaxy collection install devsec.hardening; curl https://omnitruck.chef.io/install.sh | bash -s -- -P inspec; apt-get -y install git; git clone https://github.com/figoflash/firstrepo; ansible-playbook -i localhost firstrepo/dev-sec-playbook.yml; git clone https://github.com/dev-sec/linux-baseline; inspec exec linux-baseline > /var/tmp/inspec_exec_linux-baseline.out)"]
#  tags              = local.tags
}



module "jumphost_recipe" {
  source = "rhythmictech/imagebuilder-recipe/aws"

  name = "jumphost-recipe"

  working_directory = "/tmp"

  description    = "jumphost recipe"
  parent_image   = "arn:aws:imagebuilder:ap-east-1:aws:image/minimal-ubuntu-2204-lts-jammy-a060/x.x.x"
  recipe_version = "1.2.0"
  update         = false

  component_arns = [
    "arn:aws:imagebuilder:ap-east-1:aws:component/amazon-cloudwatch-agent-linux/1.0.1/1",    
    "arn:aws:imagebuilder:ap-east-1:aws:component/simple-boot-test-linux/1.0.0/1",
    "arn:aws:imagebuilder:ap-east-1:aws:component/update-linux/1.0.2/1",
    module.jumphost_install-baseline-tools_component.component_arn,
    module.jumphost_install-cloudops-tools_component.component_arn,
    #module.jumphost_install-minimal-desktop_component.component_arn,
    #module.jumphost_devsec-os-hardening_component.component_arn
  ]
}

module "jumphost_pipeline" {
  source = "rhythmictech/imagebuilder-pipeline/aws"

  name = "jumphost-pipeline"

#  subnet = "subnet-029609d099e7e8548"
  instance_types = ["t3.micro"]
  terminate_on_failure = false

  description = "jumphost pipeline"
  public      = false
#  recipe_arn  = module.test_recipe.recipe_arn
  image_recipe_arn = module.jumphost_recipe.recipe_arn
  regions = [
  #  "us-east-1",
  #  "us-east-2"
    "ap-east-1"
  ]
  custom_distribution_configs = [
    {
      region = "ap-east-1",
      ami_distribution_configuration = {
        name = "jumphost-ami-{{ imagebuilder:buildDate }}"
        launch_permission = {
          user_ids = ["333347968576", "558294673728", "173633673455", "703375429053", "793719249882", "480546907858", "678757538058"]
        }
      }
      launch_template_configuration = {
        launch_template_id = aws_launch_template.lt-jumphost.id
      }
    },
    {
      region = "eu-west-2",
      ami_distribution_configuration = {
        name = "jumphost-ami-{{ imagebuilder:buildDate }}"
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


resource "aws_launch_template" "lt-jumphost" {
  name = "jumphost-launchtemplate2"

  instance_type = "t3.micro"

  placement {
    availability_zone = "ap-east-1a"
  }
}
