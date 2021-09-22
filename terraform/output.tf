# output "latest_centos_ami_id" {
#   value = data.aws_ami.latest_centos.id
# }
# output "LB_url" {
#   value = aws_lb.demo_front.dns_name
# }
# output "zones" {
#   value = data.aws_availability_zones.available.names
# }
#output "region-master" {
#  value = aws.region-master
#}
output "our_vpc-m" {
  value = aws_vpc.demo_vpc.id
}
output "our_sub_pub_a" {
  value = aws_subnet.demo_pub_subnet_a.cidr_block
}
output "our_sub_pub_b" {
  value = aws_subnet.demo_pub_subnet_b.cidr_block
}
output "our_sub_priv_a" {
  value = aws_subnet.demo_private_subnet_a.cidr_block
}
output "our_sub_priv_b" {
  value = aws_subnet.demo_private_subnet_b.cidr_block
}
output "DB-address" {
  value = aws_db_instance.demo_db.address
}
# output "my_bucket_file_version" {
#   value = "${aws_s3_bucket_object.file_upload.version_id}"
# }