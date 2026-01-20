terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  default = "ap-northeast-2"
}

# Grafana 워크스페이스용 IAM Role
resource "aws_iam_role" "grafana" {
  name = "demo-app-grafana-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "grafana.amazonaws.com"
      }
    }]
  })
}

# CloudWatch 읽기 권한
resource "aws_iam_role_policy" "grafana_cloudwatch" {
  name = "cloudwatch-access"
  role = aws_iam_role.grafana.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "cloudwatch:DescribeAlarmsForMetric",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricData",
        "cloudwatch:GetInsightRuleReport",
        "logs:DescribeLogGroups",
        "logs:GetLogGroupFields",
        "logs:StartQuery",
        "logs:StopQuery",
        "logs:GetQueryResults",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ]
      Resource = "*"
    }]
  })
}

# Grafana 워크스페이스
resource "aws_grafana_workspace" "demo" {
  name                     = "demo-app-monitoring"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana.arn

  data_sources = ["CLOUDWATCH"]
}

# SSO 사용자/그룹을 Grafana에 할당
variable "sso_user_id" {
  description = "IAM Identity Center 사용자 ID"
  type        = string
  default     = ""  # terraform apply 시 입력
}

resource "aws_grafana_role_association" "admin" {
  count        = var.sso_user_id != "" ? 1 : 0
  role         = "ADMIN"
  user_ids     = [var.sso_user_id]
  workspace_id = aws_grafana_workspace.demo.id
}

output "grafana_endpoint" {
  value = aws_grafana_workspace.demo.endpoint
}

output "workspace_id" {
  value = aws_grafana_workspace.demo.id
}
