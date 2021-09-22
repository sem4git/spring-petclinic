data "aws_ami" "latest_centos" {
  # provider = aws.region-master
  owners      = ["125523088429"] # CentOS
  most_recent = true

  filter {
    name   = "name"
    # values = ["CentOS 7*x86_64"] # Latest
    values = ["CentOS 8*x86_64"] # Latest
  }
}
data "aws_availability_zones" "available" {
  # provider = aws.region-master
  state    = "available"
}
# data "aws_availability_zones" "available_s" {
#   provider = aws.region-slave
#   state    = "available"
# }
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}