/* # #Create EC2 Instance 
resource "aws_instance" "Ansible_Node" {
  ami                         = "ami-0fb391cce7a602d1f"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.KMS_Frontend_SG.id}"]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.KMS_Pub_SN1.id
  availability_zone           = "eu-west-2a"
  key_name                    = var.key_name
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/KeyPair/test-key")
  }
  provisioner "file" {
    source      = "/Users/Kristina/Desktop/K8S_Project/Playbook"
    destination = "/home/ubuntu/Playbook"
  }
  provisioner "file" {
    source      = "~/KeyPair/test-key"
    destination = "/home/ubuntu/test-key"
  }

  user_data = <<-EOF
#!/bin/bash
sudo apt-get update -y
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1    
sudo apt-get install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible -y
sudo chmod 400 /home/ubuntu/test-key
sudo mkdir /etc/ansible
sudo touch /etc/ansible/hosts
sudo chown ubuntu:ubuntu /etc/ansible/hosts
sudo bash -c 'echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
sudo echo "[Main-Master]" >> /etc/ansible/hosts
sudo echo "${data.aws_instance.MainMaster.public_ip} ansible_ssh_private_key_file=/home/ubuntu/test-key" >> /etc/ansible/hosts
sudo echo "[Member-Masters]" >> /etc/ansible/hosts
sudo echo "${data.aws_instance.SubMaster1.public_ip} ansible_ssh_private_key_file=/home/ubuntu/test-key" >> /etc/ansible/hosts
sudo echo "${data.aws_instance.SubMaster2.public_ip} ansible_ssh_private_key_file=/home/ubuntu/test-key" >> /etc/ansible/hosts
sudo echo "[Workers]" >> /etc/ansible/hosts
sudo echo "${data.aws_instance.Worker1.public_ip} ansible_ssh_private_key_file=/home/ubuntu/test-key" >> /etc/ansible/hosts
sudo echo "${data.aws_instance.Worker2.public_ip} ansible_ssh_private_key_file=/home/ubuntu/test-key" >> /etc/ansible/hosts
sudo echo "${data.aws_instance.Worker3.public_ip} ansible_ssh_private_key_file=/home/ubuntu/test-key" >> /etc/ansible/hosts
sudo echo "${data.aws_instance.Worker4.public_ip} ansible_ssh_private_key_file=/home/ubuntu/test-key" >> /etc/ansible/hosts
sudo echo "[HA-lb]" >> /etc/ansible/hosts
sudo echo "${data.aws_instance.HA-Proxy.public_ip} ansible_ssh_private_key_file=/home/ubuntu/test-key" >> /etc/ansible/hosts
sudo touch /etc/ansible/ha-ip.yml
sudo chmod -R 777 /etc/ansible/ha-ip.yml
sudo echo ha_prv_ip: "${data.aws_instance.HA-Proxy.private_ip}" >> /etc/ansible/ha-ip.yml
sudo su -c 'ansible-playbook -i /etc/ansible/hosts /home/ubuntu/Playbook/installation.yml' ubuntu 
sudo su -c 'ansible-playbook -i /etc/ansible/hosts /home/ubuntu/Playbook/main-master.yml' ubuntu
sudo su -c 'ansible-playbook -i /etc/ansible/hosts /home/ubuntu/Playbook/member-master.yml' ubuntu
sudo su -c 'ansible-playbook -i /etc/ansible/hosts /home/ubuntu/Playbook/join-workers.yml' ubuntu  
sudo su -c 'ansible-playbook -i /etc/ansible/hosts /home/ubuntu/Playbook/HA-lb.yml' ubuntu
sudo su -c 'ansible-playbook -i /etc/ansible/hosts /home/ubuntu/Playbook/deployment.yml' ubuntu
   EOF 
} */
