########################################
# General Vars
########################################
variable "additional_tags" {
  default     = {}
  description = "Additional tags to add to supported resources"
  type        = map(string)
}

variable "tenable_image_id" {
  default     = "ami-083123a7aec8455fc"
  type        = string
}



