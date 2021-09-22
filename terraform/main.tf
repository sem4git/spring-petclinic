

provider "aws" {
  profile = var.profile
  region  = var.region-master
  # alias  = "region-master"
  default_tags {
    tags = {
      Owner   = "Oleksandr Semeriaha"
      Project = "Demo"
    }
  }
}

locals {
  # bucket_full_name = "${var.bucket_name}-${random_integer.bucket_prefix.result}"
  mysql_url = "jdbc:mysql://${aws_db_instance.demo_db.endpoint}/${var.db_name}?allowPublicKeyRetrieval=true&useSSL=false"
}
# resource "random_integer" "bucket_prefix" {
#   min = 1
#   max = 9999
# }
# resource "aws_s3_bucket" "app_bucket" {
#   bucket = local.bucket_full_name
#   acl    = "public-read"
#   force_destroy = true
#   # policy = file("s3_policy.json")
#   policy  = templatefile("s3_policy.json.tpl", {
#     s3_name = local.bucket_full_name
#   })
#     versioning {
#     enabled = true
#   }
# }
# resource "aws_s3_bucket_object" "file_upload" {
#   bucket = local.bucket_full_name
#   key    = "java-app/spring-petclinic.tgz"
#   source = "~/arc_app/spring-petclinic.tgz"
#   etag   = "${filemd5("~/arc_app/spring-petclinic.tgz")}"
# }

#Create key-pair for logging into EC2 in us-east-1
# resource "aws_key_pair" "master-key" {
#   key_name   = "controller"
#   public_key = file("~/.ssh/id_rsa.pub")
# }
# resource "aws_ecr_repository" "pet_rep" {
#   name                 = "petclinic"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }
# resource "null_resource" "docker_push" {
#   # provisioner "local-exec" {
#   #   command = templatefile("docker.sh.tpl", {
#   #   region = var.region
#   #   ecr_url = aws_ecr_repository.pet_rep.repository_url
#   #   })
#   # }
#   provisioner "local-exec" {
#     command = <<EOF
# aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.pet_rep.repository_url}
# docker tag 6a7bba1480a1 ${aws_ecr_repository.pet_rep.repository_url}:v1
# docker push ${aws_ecr_repository.pet_rep.repository_url}:v1
# EOF
#   }
# }
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ECSTaskExecutionRolePolicy-Demo"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_ecs_cluster" "demo_cluster" {
  name = "Demo-Cluster"
}
resource "aws_ecs_task_definition" "demo_td" {
  family = "service"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu       = 512
  memory    = 1024
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  # execution_role_arn = "arn:aws:iam::${aws_ecr_repository.pet_rep.registry_id}:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "Pet"
      image     = "${aws_ecr_repository.pet_rep.repository_url}:v1"
      essential = true
      environment = [
        {
            name = "MYSQL_USER"
            value = "${aws_ssm_parameter.db_user.value}"
        },
        {
            name = "MYSQL_PASS"
            value = "${aws_ssm_parameter.db_password.value}"
        },
        {
            name = "MYSQL_URL"
            value = "${local.mysql_url}"
        },
        {
            name = "spring_profiles_active"
            value = "mysql"
        }
      ]
      portMappings = [
        {
          containerPort = 8080
          # hostPort      = 8080
        }
      ]
    }
  ])

  # volume {
  #   name      = "service-storage"
  #   host_path = "/ecs/service-storage"
  # }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }
}
resource "aws_ecs_service" "demo" {
  name            = "Demo-Service"
  cluster         = aws_ecs_cluster.demo_cluster.id
  task_definition = aws_ecs_task_definition.demo_td.arn
  desired_count   = "2"
  launch_type     = "FARGATE"
  # iam_role        = "${aws_iam_role.svc.arn}"

  # deployment_maximum_percent         = "${var.deployment_maximum_percent}"
  # deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"
  # network_configuration {
  #   subnets         = [aws_subnet.demo_pub_subnet_a.id, aws_subnet.demo_pub_subnet_b.id]
  # }
  load_balancer {
    # elb_name = aws_elb.demo_front.name
    target_group_arn = aws_lb_target_group.demo_front.arn
    container_name   = "Pet"
    container_port   = 8080
  }
  network_configuration {
    security_groups = [aws_security_group.web.id]
    assign_public_ip = true
    subnets         = [aws_subnet.demo_pub_subnet_a.id, aws_subnet.demo_pub_subnet_b.id]
  }
}
resource "aws_security_group" "web" {
  name        = "Demo-Web-SG"
  description = "Demo Web Security Group"
  vpc_id      = aws_vpc.demo_vpc.id

  dynamic "ingress" {
    for_each = ["22", "80", "8080"]
    content {
      description = "SSH and HTTP to Front"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "demo_front" {
  name            = "Demo-Frontend-ALB"
  internal           = false
  load_balancer_type = "application"
  subnets         = [aws_subnet.demo_pub_subnet_a.id, aws_subnet.demo_pub_subnet_b.id]
  security_groups = [aws_security_group.web.id]
}
resource "aws_lb_listener" "demo_front" {
  load_balancer_arn = aws_lb.demo_front.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo_front.arn
  }
}
resource "aws_lb_target_group" "demo_front" {
  name        = "Demo-target-group"
  port        = 8080
  target_type = "ip"
  vpc_id      = aws_vpc.demo_vpc.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 15
    path     = "/"
    port     = 8080
    protocol = "HTTP"
    matcher  = "200-299"
  }
  # tags = {
  #   Name = "Demo-target-group"
  # }
}
# resource "aws_elb" "demo_front" {
#   name            = "Demo-Frontend-ELB"
#   subnets         = [aws_subnet.demo_pub_subnet_a.id, aws_subnet.demo_pub_subnet_b.id]
#   security_groups = [aws_security_group.web.id]
#   listener {
#     lb_port           = 80
#     lb_protocol       = "http"
#     instance_port     = 8080
#     instance_protocol = "http"
#   }
#   #  health_check {
#   #    healthy_threshold   = 2
#   #    unhealthy_threshold = 2
#   #    target              = "HTTP:8080/"
#   #    timeout             = 3
#   #    interval            = 10
#   #  }
# }
#=================================================================================================
resource "random_password" "rds_password_back" {
  length           = 16
  special          = true
  override_special = "!#*&"
}


resource "aws_ssm_parameter" "db_password" {
  name        = "/production/database/password"
  description = "BD Password"
  type        = "SecureString"
  value       = random_password.rds_password_back.result

  tags = {
    environment = "production"
  }
}
resource "aws_ssm_parameter" "db_user" {
  name        = "/production/database/user"
  description = "DB User"
  type        = "SecureString"
  value       = var.db_user

  tags = {
    environment = "production"
  }
}

resource "aws_db_subnet_group" "demo_dbsg" {
  name       = "main"
  subnet_ids = [aws_subnet.demo_private_subnet_a.id, aws_subnet.demo_private_subnet_b.id]

  tags = {
    Name = "Demo-DB-subnet-group"
  }
}
resource "aws_security_group" "db" {
  name        = "Demo-DB-SG"
  description = "Demo DB Security Group"
  vpc_id      = aws_vpc.demo_vpc.id

  dynamic "ingress" {
    for_each = ["3306"]
    content {
      description = "Allow connection to MySQL"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "demo_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  vpc_security_group_ids = [aws_security_group.db.id]
  identifier           = var.db_name
  name                 = var.db_name
  username             = aws_ssm_parameter.db_user.value
  password             = aws_ssm_parameter.db_password.value
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately    = true
  db_subnet_group_name = aws_db_subnet_group.demo_dbsg.name

}

