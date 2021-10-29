#output.tf

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "aws_region" {
  value = data.aws_region.current.name
}



output "instance_ip_addr" {
  value       = aws_instance.ec2_instance[*].private_ip
  description = "The private IP address of the main server instance."
}


output "subnet_name" {
  value = aws_instance.ec2_instance[*].subnet_id
}


output "instance_public_ip" {
  value       = aws_instance.ec2_instance[*].public_ip
  description = "The publice IP address of the main server instance."
}
