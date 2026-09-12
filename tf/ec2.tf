# key pair (Login)
resource aws_key_pair my-key {
    key_name = "terraform-key-ec2"
    public_key = file("terraform-key-ec2.pub")

}
# VPC & Security Group
resource "aws_default_vpc" "default" {

}
resource aws_security_group "my-sg" {
  name = "my-security-group"
  description = "My security group"
  vpc_id = aws_default_vpc.default.id

  #inbound rule
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow SSH access from anywhere"
}
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP access from anywhere"
}
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS access from anywhere"
}
    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow custom traffic from anywhere"
    }

    
# outbound rule
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
}
}


# EC2 Instance

resource "aws_instance" "my_instance" {
     #meta argument 
     for_each = tomap({
        PK-automate-micro = "t3.micro",
        KP-automate-small = "t3.small",
        automate-pk-micro = "t3.micro"
     })
    key_name = aws_key_pair.my-key.key_name
    security_groups = [aws_security_group.my-sg.name]
    instance_type = each.value # meta argument refer
    ami = var.ec2_ami_id#ubuntu os 
    # user_data_replace_on_change = true
    user_data = file("install_nginx.sh")
    user_data_replace_on_change = true
    root_block_device {
        volume_size = var.ec2_root_storage_size
        volume_type = "gp3"

    }
    tags = {
        Name = each.key
    }
}
  

