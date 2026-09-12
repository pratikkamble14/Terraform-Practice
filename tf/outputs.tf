# output "ec2_public_ip" {
#   value = aws_instance.my_instance[*].public_ip
# }

# output "ec2_public_dns" {
#   value = aws_instance.my_instance[*].public_dns
# }

# output "ec2_private_ip" {
#   value = aws_instance.my_instance[*].private_ip
# }



# by using for each

output "aws_instance" {
  value = [
    for i in aws_instance.my_instance : i.public_ip    
  ]
}