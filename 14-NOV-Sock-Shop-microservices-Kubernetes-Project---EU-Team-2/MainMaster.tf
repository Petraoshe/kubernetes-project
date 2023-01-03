/* #Create EC2 Instance 
resource "aws_instance" "MainMaster" {
  ami                         = "ami-0fb391cce7a602d1f"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.KMS_Frontend_SG.id}"]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.KMS_Pub_SN1.id
  # availability_zone           = "eu-west-2a"
  key_name                    = var.key_name
  tags = {
    Name = "MainMaster_1"
  }
}
data "aws_instance" "MainMaster" {
  filter {
    name   = "tag:Name"
    values = ["MainMaster_1"]
  }
  depends_on = [
    aws_instance.MainMaster
  ]
} */