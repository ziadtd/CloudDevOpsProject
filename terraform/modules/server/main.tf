resource "aws_security_group" "jenkins" {
  name_prefix = "${var.project_name}-${var.environment}-jenkins-"
  description = "Security group for Jenkins server"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Jenkins web interface"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "jenkins" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}-jenkins"
  retention_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-jenkins-logs"
    }
  )
}

resource "aws_instance" "jenkins" {
  ami                    = var.amazon_linux_2_ami_id
  instance_type          = var.jenkins_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = var.iam_instance_profile_name

  monitoring = true

  user_data = templatefile("${path.module}/user-data.sh", {
    log_group_name = aws_cloudwatch_log_group.jenkins.name
  })
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }



  lifecycle {
    ignore_changes = [ami]
  }

  depends_on = [
    aws_cloudwatch_log_group.jenkins
  ]
}

resource "aws_cloudwatch_metric_alarm" "jenkins_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-jenkins-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors Jenkins EC2 CPU utilization"
  alarm_actions       = []

  dimensions = {
    InstanceId = aws_instance.jenkins.id
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "jenkins_status_check" {
  alarm_name          = "${var.project_name}-${var.environment}-jenkins-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors Jenkins EC2 status checks"
  alarm_actions       = []

  dimensions = {
    InstanceId = aws_instance.jenkins.id
  }

  tags = var.common_tags
}
