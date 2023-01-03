/* #Create EC2 Instance 
resource "aws_instance" "Worker3" {
  ami                         = "ami-0fb391cce7a602d1f"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.KMS_Frontend_SG.id}"]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.KMS_Pub_SN2.id
  key_name                    = var.key_name
  tags = {
    Name = "Worker_3"
  }
}
data "aws_instance" "Worker3" {
  filter {
    name   = "tag:Name"
    values = ["Worker_3"]
  }
  depends_on = [
    aws_instance.Worker3
  ]
} */