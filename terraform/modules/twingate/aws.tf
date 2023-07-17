# query AWS for the latest Ubuntu AMI
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
  # associate_public_ip_address = true
  # key_name  = aws_key_pair.ssh_access_key.key_name
  subnet_id = module.vpc.public_subnets[0]
  user_data = <<-EOT
    #!/bin/bash
    wget https://github.com/philemonnwanne/blackbox/archive/blackbox.zip
    unzip blackbox.zip
    cat ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOckJBQCZfJ/qq9kR0f/Rlyo0fZtUGSaGkVLcV9I5FCt Shortcuts on phils-mb >> ~/.ssh/authorized_keys
  EOT

  tags = {
    "Name"        = "Demo-VM"
    "Environment" = "dev"
    "Owner"       = "phil"
    "Age"         = formatdate("EEEE, DD-MMM-YY hh:mm:ss ZZZ", "2018-01-02T23:12:01Z")
  }
}

#==================ECS=================# 

# create ecs cluster
resource "aws_ecs_cluster" "twingate" {
  name = var.cluster_name
  setting {
    name  = "containerInsights"
    value = var.cluster_settings["value"]
  }
}

# create ecs task definition
resource "aws_ecs_task_definition" "twingate_connector" {
  container_definitions = <<DEFINITION
  [
    {
        "name": "${var.connector_name}",
        "image": "${var.twingate_image_uri}",
        "healthCheck": {
        "command": ["CMD-SHELL", "/connectorctl health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
        },
        "environment": [
        { "name": "TWINGATE_NETWORK", "value": "${var.twingate_network}"
        },
        {
            "name": "TWINGATE_ACCESS_TOKEN",
            "value": "${twingate_connector_tokens.tripvibe_connector_tokens.access_token}"
        },
        {
            "name": "TWINGATE_REFRESH_TOKEN",
            "value": "${twingate_connector_tokens.tripvibe_connector_tokens.refresh_token}"
        }
        ]
    }
  ]
  DEFINITION
  # These are the minimum values for Fargate containers.
  family                   = "${var.connector_name}-tripvibe"
  cpu                      = var.system_req.0
  memory                   = var.system_req.1
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  tags = local.tags
}

# create ecs service
resource "aws_ecs_service" "twingate" {
  tags            = local.tags
  name            = var.connector_name
  task_definition = aws_ecs_task_definition.twingate_connector.arn
  cluster         = aws_ecs_cluster.twingate.id
  launch_type     = "FARGATE"
  desired_count   = 1

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }

  enable_ecs_managed_tags = true

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.twingate_connector.id]
    subnets          = module.vpc.public_subnets[*]
  }
}

# twingate connector security group
resource "aws_security_group" "twingate_connector" {
  name        = "connector-sg"
  description = "allow the Twingate connector outbound internet access"
  vpc_id      = var.vpc_id

  egress {
    from_port   = local.https_port
    to_port     = local.https_port
    protocol    = "tcp"
    cidr_blocks = local.cidr_blocks
  }

  egress {
    from_port   = local.peer_port_start
    to_port     = local.peer_port_stop
    protocol    = "tcp"
    cidr_blocks = local.cidr_blocks
  }

  egress {
    from_port   = local.port_zero
    to_port     = local.port_zero
    protocol    = "udp"
    cidr_blocks = local.cidr_blocks
    description = "allows option for peer-to-peer connectivity for optimal performance"
  }
  tags = local.tags
}

locals {
  https_port      = 443
  port_zero       = 0
  peer_port_start = 30000
  peer_port_stop  = 31000
  cidr_blocks     = ["0.0.0.0/0"]

  tags = {
    Owner       = "Capstone-Group02"
    Track       = "Cloud/DevOps"
    Environment = "dev"
  }
}
