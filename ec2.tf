/*
 *  =======================================
 *             EC2 for NextJS App
 *  =======================================
 */


resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = <<-EOL
  #!/bin/bash -xe

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
  . ~/.nvm/nvm.sh
  nvm install node
  node -v
  npm -v
  sudo yum update -y
  sudo yum install git -y
  git —-version
  git clone https://github.com/swen-514-614-fall2022/term-project-team-2.git
  cd term-project-team-2/app
  npm install
  npm run dev
  EOL

  tags = {
    Name = "HelloWorld"
  }
}
