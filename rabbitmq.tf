resource "aws_spot_instance_request" "rabbitmq" {
#   ami                    = data.aws_ami.base-ami.image_id
  ami                    = "ami-063dd2bd5641ef903"
  instance_type          = var.RABBITMQ_INSTANCE_TYPE
  wait_for_fulfillment   = true 
  vpc_security_group_ids = [aws_security_group.allow_rabbitmq.id]
  subnet_id              = data.terraform_remote_state.vpc.outputs.PUBLIC_SUBNET_ID[0]

  tags = {
    Name = "rabbitmq-${var.ENV}"
  }
}

resource "null_resource" "rabbitmq-installation" {
  # triggers = {    
  #       a = timestamp()  # Everytime you run, when compared to the last time, the time changes, so it will be triggered all the time.
  #   }
  provisioner "remote-exec" {
      connection {
        type     = "ssh"
        user     = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_USER"]
        password = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_PASS"]
        # host     = self.public_ip
        host     = aws_spot_instance_request.rabbitmq.private_ip
      } 
    inline = [
     "ansible-pull -U https://github.com/codesud/ansible.git -e COMPONENT=rabbitmq -e ENV=dev roboshop.yml && sudo disable-auto-shutdown"
      
      ]
    }
}