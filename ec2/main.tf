resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  availability_zone = "us-west-2a"

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  subnet_id = aws_subnet.main.id
}