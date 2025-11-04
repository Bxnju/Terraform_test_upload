provider "aws" {
  region = "us-east-1"  # cambia según tu región
}

resource "aws_instance" "flask_server" {
  ami           = "ami-0ecb62995f68bb549"  # ejemplo Ubuntu 22.04 en us-east-1
  instance_type = "t2.micro"
  #key_name      = "mi-key-aws"

  user_data = <<-EOF
              #!/bin/bash
              set -e
              sudo apt update -y
              sudo apt install -y git python3-pip
              # Clona tu repo público
              git clone https://github.com/Bxnju/Terraform_test_upload.git /home/ubuntu/app
              chown -R ubuntu:ubuntu /home/ubuntu/app

              if [ -f /home/ubuntu/app/requirements.txt ]; then
                pip3 install -r /home/ubuntu/app/requirements.txt
              else
                pip3 install Flask==2.3.2
              fi

              # Ejecuta la app (simple, para testing)
              nohup python3 /home/ubuntu/app/app.py > /home/ubuntu/app/app.log 2>&1 &
              EOF

  tags = {
    Name = "FlaskServer"
  }

  # Seguridad: permitir puerto 80
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
}

resource "aws_security_group" "flask_sg" {
  name        = "flask_sg"
  description = "Allow HTTP"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
