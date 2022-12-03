resource "aws_instance" "front-end" {
  ami                    = "ami-032f3250cf84bd208"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_a.id
  vpc_security_group_ids = ["${aws_security_group.instance_security_group.id}"]
  user_data              = <<EOF
    git clone "${var.git_repo}"
    cd term-project-team-2/src/app/
    echo NEXT_PUBLIC_ENDPOINT="${aws_apigatewayv2_stage.api_gw.invoke_url}" >> .env
    npm i next
    npm run build
    pm2 start npm --name "next" -- start
    systemctl start nginx
  EOF
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "tf-vpc"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.front-end.id}"
  vpc      = true
}

resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_internet_gateway_attachment" "attach_gateway" {
  vpc_id              = aws_vpc.vpc.id
  internet_gateway_id = aws_internet_gateway.internet_gateway.id
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/26"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "tf-public-subnet-a"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    "Name" = "tf-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_a_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "instance_security_group" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "url" {
  value = "http://${aws_instance.front-end.public_ip}"
}