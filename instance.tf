resource "aws_instance" "instance"
{
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${var.security_group}"]
  associate_public_ip_address = "${var.provider["associate_public_ip_address"]}"
  subnet_id = "${var.subnet_id}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "${var.root_device_size}"
    delete_on_termination = true
  }


  provisioner "file" {
    source      = "user_data.sh"
    destination = "/tmp/user_data.sh"
    connection {
      type     = "ssh"
      user     = "${var.os_user}"
      private_key = "${file(var.key_path)}"
      agent = "${var.use_ssh_agent}"
    }

  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/user_data.sh",
      "/tmp/user_data.sh",
      "echo -e \"\n\" | ssh-keygen -t rsa -N \"\"",

    ]

    connection {
      type     = "ssh"
      user     = "${var.os_user}"
      private_key = "${file(var.key_path)}"
      agent = "${var.use_ssh_agent}"
    }
  }

  provisioner "local-exec" {
    command = "sleep 10 && export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook  -i ${aws_instance.instance.public_ip}, rabbitmq.yml -e \"host=all ssh_user=${var.os_user}\" -v -u ${var.os_user} --key-file=${var.key_path}"
  }

  tags
  {
    Name = "${var.instance_name}"
    StateAction = "StartAndStop"

  }
  volume_tags
  {
    Name = "${var.instance_name}"
  }

}

output "rabbitmq_url" {
value = "http://${aws_instance.instance.public_ip}:15672"
}


