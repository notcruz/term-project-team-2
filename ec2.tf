/*
 *  =======================================
 *             EC2 for NextJS App
 *  =======================================
 */




resource "aws_instance" "web" {
  ami           = "ami-08c40ec9ead489470"
  instance_type = "t3.micro"


  user_data = <<-EOL
  #!/bin/bash -xe

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
  . ~/.nvm/nvm.sh
  export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm install 14
  node -v
  npm -v
  sudo apt-get update -y
  sudo apt-get install git -y
  
  npm i -g pm2
  sudo apt-get update
  sudo apt-get install nginx -y
  

  git —-version
  git clone https://github.com/swen-514-614-fall2022/term-project-team-2.git
  
  cd term-project-team-2/app
  npm install
  npm run build
  npm run dev
  EOL

  tags = {
    Name = "SentimentFrontEnd"
  }
}

resource "local_file" "name" {
  content  = "server {listen 80 default;server_name _;location /{proxy_pass http://127.0.0.1:8080;}}"
  filename = "$/etc/nginx/SentimentFrontEnd.conf"
}
