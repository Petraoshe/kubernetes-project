/* #Create EC2 Instance 
resource "aws_instance" "HA_Proxy" {
  ami                         = "ami-0fb391cce7a602d1f"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.KMS_Frontend_SG.id}"]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.KMS_Pub_SN1.id
  availability_zone           = "eu-west-2a"
  key_name                    = var.key_name

  user_data = <<-EOF
#!/bin/bash
sudo -i
apt-get update -y
apt-get upgrade -y
apt install --no-install-recommends software-properties-common
add-apt-repository ppa:vbernat/haproxy-2.4 -y
apt install haproxy=2.4.\* -y
haproxy -v
sudo bash -c 'echo "
frontend fe-apiserver
bind 0.0.0.0:6443
mode tcp
option tcplog
default_backend be-apiserver
backend be-apiserver
mode tcp
option tcplog
option tcp-check
balance roundrobin
default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server master1 ${data.aws_instance.MainMaster.public_ip}:6443 check
    server master3 ${data.aws_instance.SubMaster1.public_ip}:6443 check
    server master2 ${data.aws_instance.SubMaster2.public_ip}:6443 check" > /etc/haproxy/haproxy.cfg'
systemctl restart haproxy
hostnamectl set-hostname HA-LB-node
   EOF 
  tags = {
    Name = "HA_Proxy"
  }
}
data "aws_instance" "HA-Proxy" {
  filter {
    name   = "tag:Name"
    values = ["HA_Proxy"]
  }
  depends_on = [
    aws_instance.HA_Proxy
  ]
} */