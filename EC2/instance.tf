provider "aws" {
	region = "us-west-1"
	shared_credentials_file = "/home/anderson/.aws/credentials"
	profile = "terraform-test"
}

resource "aws_instance" "teste-terraform" {
	ami = "ami-03fac5402e10ea93b"
	instance_type = "t2.micro"
	# key_name = "aws_key_pair.my-key.key_name"
	# security_groups = ["${aws_security_group.allow_ssh.name}"]
}

resource "aws_key_pair" "my-key" {
	key_name = "my-key"
	public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh" {
	name = "allow_ssh"
	# SSH access
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

output "example_public_dns" {
	value = "${aws_instance.teste-terraform.public_dns}"
}

