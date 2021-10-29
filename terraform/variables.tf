#variables.tf

variable "test_foreach_instances" {  # карта с параметрами инстансов для создания с помощью цикла for_each
  description = "Keeps instances parameters"
  type        = map
  default     = {
    amazon = {
      instance_type = "t3.micro",
      ami = "ami-0d15082500b576303",
      tags = {
        Name = "Amazon Linux"
      }
    },
    opensuse = {
      instance_type = "t3.micro",
      ami = "ami-00d7bb1aabce7d22c",
      tags = {
        Name = "OpenSUSE Linux"
      }
    }
  }
}