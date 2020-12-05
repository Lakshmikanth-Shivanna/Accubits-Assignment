resource "aws_security_group" "ec2-sg" {
  name   = "ec2_sg"
# HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1b"

  tags = {
    Name = "Default subnet for us-east-2a"
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-2a"
  }
}


resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2-sg.id]
  subnets = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "front_end" {
  name = "frontend-target-group"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}



resource "aws_alb_target_group_attachment" "instance1" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id = aws_instance.instance1.id

}

resource "aws_alb_target_group_attachment" "instance2" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id = aws_instance.instance2.id

}

