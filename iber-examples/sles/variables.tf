########################################
# General Vars
########################################
variable "additional_tags" {
  default     = {}
  description = "Additional tags to add to supported resources"
  type        = map(string)
}

variable "cmdline1" {
  default     = ""
  description = "set of commands to enable selinux"
  type        = string
}



