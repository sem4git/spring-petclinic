variable "profile" {
  type    = string
  default = "default"
}
variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}
variable "region-master" {
  description = "Region Master"
  type        = string
  default     = "us-east-1"
}
variable "region-slave" {
  description = "Region Slave"
  type        = string
  default     = "us-west-2"
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
variable "db_password" {
  description = "Data Base password"
  type        = string
  default     = "petclinic2"
}
variable "bucket_name" {
  description = "S3 Bucket Name"
  type        = string
  default     = "test-backet"
}