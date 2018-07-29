variable "provider"
{
	type = "map"
	default = {
		timeout = "25m"
		associate_public_ip_address = "true"
	}
}

variable "instance_name"  { default = "rabbitmq" }
variable "subnet_id" {}
variable "ami" {default = "ami-571e3c30"}
variable "key_path" {}
variable "key_name" {}
variable "use_ssh_agent" {default = "false"}
variable "security_group" {}
variable "os_user" {default = "centos"}
variable "instance_type" {default = "t2.micro"}
variable "root_device_size" {default = "12"}

