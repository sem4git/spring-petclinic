variable "profile" {
  type    = string
  default = "default"
}
variable "region" {
  description = "Region"
  type        = string
  default     = "eu-central-1"
}
variable "region-master" {
  description = "Region Master"
  type        = string
  default     = "eu-central-1"
}
variable "instance_type" {
  description = "The type of EC2 Instances to run"
  type        = string
  default     = "t2.micro"
}
variable "db_name" {
  description = "Data Base Name"
  type        = string
  default     = "petclinic"
}
variable "db_user" {
  description = "Data Base User"
  type        = string
  default     = "petclinic1"
}