provider "aws" {
  region = "us-east-1"
}

# Step 1: Creating a VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo"
  }
}

# Step 2: Creating Subnets
resource "aws_subnet" "demo_subnet" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "demo1"
  }
}

# Step 3: Setting Up Security Groups
resource "aws_security_group" "demo_sg" {
  vpc_id = aws_vpc.demo_vpc.id
  description = "Security group for my application"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo"
  }
}

# Step 4: Creating an RDS Database
resource "aws_db_instance" "demo_db" {
  identifier              = "demo-db"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t2.micro"
  name                    = "demo"
  username                = "admin"
  password                = "password"
  publicly_accessible     = true
  vpc_security_group_ids  = [aws_security_group.demo_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.demo_subnet_group.name

  tags = {
    Name = "demo"
  }
}

resource "aws_db_subnet_group" "demo_subnet_group" {
  name       = "demo-subnet-group"
  subnet_ids = [aws_subnet.demo_subnet.id]

  tags = {
    Name = "demo"
  }
}

# Step 5: Configuring the Application
# (Update PHP application with the RDS connection details manually in the code)

# Step 6: Setting Up EC2 and Auto Scaling
resource "aws_launch_template" "demo_launch_template" {
  name          = "demo-launch-template"
  image_id      = "ami-0c55b159cbfafe1f0" # Ubuntu AMI ID (change as needed)
  instance_type = "t2.micro"
  key_name      = "my-key"

  user_data = <<-EOF
              #!/bin/bash
              sudo su 
              apt update -y
              apt install apache2 -y
              apt install php libapache2-mod-php php-mysql -y
              apt install mysql-client -y
              apt install rar unrar zip unzip -y
              apt install git -y
              cd /var/www/html/
              git clone https://github.com/Vimal007Vimal/AWS-2-tier-application.git
              rm -f index.html
              cd AWS-2-tier-application 
              mv * /var/www/html/
              cd ..
              rmdir AWS-2-tier-application
              systemctl restart apache2
              systemctl enable apache2
              EOF
}

resource "aws_autoscaling_group" "demo_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.demo_subnet.id]
  launch_template {
    id      = aws_launch_template.demo_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "demo-instance"
    propagate_at_launch = true
  }
}

resource "aws_elb" "demo_elb" {
  name               = "demo-elb"
  availability_zones = ["us-east-1a"]
  listeners {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  instances = aws_autoscaling_group.demo_asg.instances
}

# Step 8: Setting Up Monitoring and Notifications
resource "aws_sns_topic" "demo_sns_topic" {
  name = "demo"
}

resource "aws_sns_topic_subscription" "demo_sns_subscription" {
  topic_arn = aws_sns_topic.demo_sns_topic.arn
  protocol  = "email"
  endpoint  = "your-email@example.com" # Change to your email
}

resource "aws_cloudwatch_metric_alarm" "demo_alarm" {
  alarm_name                = "demo-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 1
  alarm_actions             = [aws_sns_topic.demo_sns_topic.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.demo_asg.name
  }
}

output "elb_dns_name" {
  value = aws_elb.demo_elb.dns_name
}
