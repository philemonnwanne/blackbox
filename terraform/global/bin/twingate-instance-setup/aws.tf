# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "twingate-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main Subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-gateway"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" #allow all
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}

# query AWS for the latest Twingate AMI
data "aws_ami" "twingate" {
  most_recent = true

  filter {
    name   = "name"
    values = ["twingate/images/hvm-ssd/twingate-amd64-*"]
  }

  owners = ["617935088040"] # Twingate
}

# create a Twingate connector
resource "aws_instance" "twingate_connector" {
  ami                         = data.aws_ami.twingate.id
  instance_type               = "t3.nano"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh_access_key.key_name
  subnet_id                   = aws_subnet.main.id
  user_data                   = <<-EOT
    #!/bin/bash
    set -e
    mkdir -p /etc/twingate/
    {
      echo TWINGATE_URL="https://${var.tg_network}.twingate.com"
      echo TWINGATE_ACCESS_TOKEN="${twingate_connector_tokens.tripvibe_connector_tokens.access_token}"
      echo TWINGATE_REFRESH_TOKEN="${twingate_connector_tokens.tripvibe_connector_tokens.refresh_token}"
    } > /etc/twingate/connector.conf
    sudo systemctl enable --now twingate-connector
  EOT

  tags = {
    "Name" = "Twingate-Connector"
  }
}

# query AWS for the latest Ubunutu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# create an SSH access key
resource "aws_key_pair" "ssh_access_key" {
  key_name   = "~/.ssh/twingate_id_rsa"
  public_key = file("~/.ssh/twingate_id_rsa.pub")
}

# create a test VM [private]
resource "aws_instance" "test" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.nano"
  key_name      = aws_key_pair.ssh_access_key.key_name
  subnet_id     = aws_subnet.main.id

  tags = {
    "Name" = "Demo-VM"
    "Environment" = "dev"
    "Owner" = "phil"
    "Age" = formatdate("EEEE, DD-MMM-YY hh:mm:ss ZZZ", "2018-01-02T23:12:01Z")
  }
}
