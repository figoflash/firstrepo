module "sles15_enable_auth_cron_log_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "sles15_enable_auth_cron_log_component"
  name              = "sles15_enable_auth_cron_log_component"
  commands          = ["(echo $'cron.* /var/log/cron.log\nauth.* /var/log/auth.log' >> /etc/rsyslog.conf)"]
#  tags              = local.tags
}

locals {
  cmdline1 = file("./enable_selinux.sh")
}

module "sles15_enable_selinux_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "sles15_enable_selinux_component"
  name              = "sles15_enable_selinux_component"
#  commands          = ["(source /etc/os-release; zypper ar -f --no-gpgcheck https://download.opensuse.org/repositories/security:/SELinux_legacy/$VERSION_ID/ SELinux-Legacy; zypper --non-interactive in restorecond policycoreutils setools-console; zypper --non-interactive in selinux-policy-targeted selinux-policy-devel; sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=.*\)"$/\1 security=selinux selinux=1"/' /etc/default/grub; grub2-mkconfig -o /boot/grub2/grub.cfg)"]
  commands          = ["${local.cmdline1}"] 
}


module "sles15_config_cwagent_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "sles15_config_cwagent_component"
  name              = "sles15_config_cwagent_component"
  commands          = ["(/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-securitylab-cw-config)"]
#  tags              = local.tags
}



module "sles15_install-xrdp_component" {
  source  = "rhythmictech/imagebuilder-component-shell/aws"
  version = "2.1.2"

  component_version = "1.0.0"
  description       = "sles15_install-xrdp component"
  name              = "sles15_install-xrdp-component"
  commands          = ["(zypper install -y xrdp; systemctl enable xrdp; systemctl start xrdp)"]
#  tags              = local.tags
}


module "sles15_recipe" {
  source = "rhythmictech/imagebuilder-recipe/aws"

  name = "sles15-recipe"

  working_directory = "/tmp"

  description    = "SLES15 recipe"
  parent_image   = "arn:aws:imagebuilder:ap-east-1:aws:image/suse-linux-enterprise-server-15-x86/x.x.x"
  recipe_version = "1.0.0"
  update         = false

  component_arns = [
    "arn:aws:imagebuilder:ap-east-1:aws:component/amazon-cloudwatch-agent-linux/1.0.1/1",    
    module.sles15_config_cwagent_component.component_arn,
    module.sles15_install-xrdp_component.component_arn,
    module.sles15_enable_selinux_component.component_arn,
    module.sles15_enable_auth_cron_log_component.component_arn,
    "arn:aws:imagebuilder:ap-east-1:aws:component/update-linux/1.0.2/1",
    "arn:aws:imagebuilder:ap-east-1:aws:component/simple-boot-test-linux/1.0.0/1",
  ]
}

module "sles15_pipeline" {
  source = "rhythmictech/imagebuilder-pipeline/aws"

  name = "sles15-pipeline"

#  subnet = "subnet-029609d099e7e8548"
  instance_types = ["t3.micro"]
#  security_group_ids = ["sg-07f2889d86b5e50b3"]

  description = "SLES15 pipeline"
  public      = false
  image_tests_enabled = true
#  recipe_arn  = module.test_recipe.recipe_arn
  image_recipe_arn = module.sles15_recipe.recipe_arn
  regions = [
  #  "us-east-1",
  #  "us-east-2"
    "ap-east-1"
  ]
  custom_distribution_configs = [
    {
      region = "ap-east-1",
      ami_distribution_configuration = {
        name = "sles15-ami-{{ imagebuilder:buildDate }}"
        launch_permission = {
          user_ids = ["333347968576", "558294673728", "173633673455", "703375429053", "793719249882", "480546907858", "678757538058"]
        }
      }
      launch_template_configuration = {
        launch_template_id = aws_launch_template.lt-sles15.id
      }
    },
    {
      region = "eu-west-2",
      ami_distribution_configuration = {
        name = "sles15-ami-{{ imagebuilder:buildDate }}"
        launch_permission = {
          user_ids = ["333347968576", "558294673728", "173633673455", "703375429053", "793719249882", "480546907858", "678757538058"]
        }
      }
      # pre-created in eu-west-2
      launch_template_configuration = {
        launch_template_id = "lt-0808889b9aeed5741"
      }

    }
  ]
}


resource "aws_launch_template" "lt-sles15" {
  name = "sles15-launchtemplate"

  instance_type = "t3.micro"

  placement {
    availability_zone = "ap-east-1a"
  }
}
