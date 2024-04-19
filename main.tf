
provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"

}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id     = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBGDYomP9z6kRjxkvYKU45aEYocCVoauewnP4uYJEwqA2qhUwxZCopKcouB5wxlrNzva+lOwRMq22hE0mWaY+Cnb+LwmO91gWiK6tSBS5x5gt7ZqDAZ7BK6JOHGl5869JtPMKvoHVhFJ9uYkjZ6QKAsK4RESCASnYTn8msFICecFy3Yo84TRRjsQ5OiEWWPkLtUTGLHbbh3k1e3jjZH4SQI6/qiH1+7ZR0EQ7O2Y2rzLytLfNKH97Xo53/U1wNMP6llo8glydBVKBK0Zwz8B8tfJd1A4Oo0Luog3OcfJpTmMF2DNFbvyAFl19lCtLccAjkC6etI+224hFy2uG1RGenYvUiMRpor8HMqsFm563b/xl/QziDePhlam+L/iZAend+oIyQ0Ah2ve0H+El9RJefSFFePakxZ/bw+mNiaRD3m/0HZ78jywd1C3X+gEkgjd9VER5MQzFEdreXkcwi/pYLrreY4wtA0xnvHVGaZHCiuOJvDn9OloA3VhQKQDmc/jzaUlO1A4JN843TYbWtEeBLqJFcHfDAgVJlBAWel0oUk/L9Oh2ve6+g4e4HkOEH/X0vbMI6/tImiAYo69lZfNQm3rydLpsNYI2argE1Y42RTpkZIGC+VQYVn6TUcblK8hLv+jHkEPH/XKKSRJOAP+p6UnvudANxV90xZA5auVc3kQ== lukasz@mbp-lukasz.home"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  availability_zone = "us-west-2a"

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  subnet_id = aws_subnet.main.id
}

resource "aws_iam_role" "example" {
  name = "example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "example" {
  name = "example"
  role = aws_iam_role.example.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "buckettest" {
  bucket = "buckettestluk88"
  acl    = "private"

  tags = {
    Name        = "My-bucket"
    Environment = "Dev"
  }
}