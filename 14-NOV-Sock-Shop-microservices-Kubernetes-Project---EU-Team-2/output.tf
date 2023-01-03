output "vpc_ID" {
  description = "vpc_ID"
  value       = aws_vpc.KMS_vpc.id
}

/* output "Ansible_Node_Public_IP" {
  value       = aws_instance.Ansible_Node.public_ip
  description = "Ansible_Node Public IP"
}

output "HA_Proxy_Public_IP" {
  value       = aws_instance.HA_Proxy.public_ip
  description = "HA_Proxy Public IP"
}

output "HA_Proxy_Private_IP" {
  value       = aws_instance.HA_Proxy.private_ip
  description = "HA_Proxy Private IP"
}

output "MainMaster_Public_IP" {
  value       = aws_instance.MainMaster.public_ip
  description = "MainMaster Public IP"
}

output "SubMaster1_Public_IP" {
  value       = aws_instance.SubMaster1.public_ip
  description = "SubMaster1 Public IP"
}

output "SubMaster2_Public_IP" {
  value       = aws_instance.SubMaster2.public_ip
  description = "SubMaster2 Public IP"
}

output "Worker1_Public_IP" {
  value       = aws_instance.Worker1.public_ip
  description = "Worker1 Public IP"
}

output "Worker2_Public_IP" {
  value       = aws_instance.Worker2.public_ip
  description = "Worker2 Public IP"
}

output "Worker3_Public_IP" {
  value       = aws_instance.Worker3.public_ip
  description = "Worker3 Public IP"
}

output "Worker4_Public_IP" {
  value       = aws_instance.Worker4.public_ip
  description = "Worker4 Public IP"
} */

output "Jenkins" {
  value = aws_instance.Jenkins.public_ip
}