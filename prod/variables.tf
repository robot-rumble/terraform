variable "aws_region" {
  default = "us-east-1"
}

variable "app_image" {
  default = "docker.pkg.github.com/robot-rumble/backend/robot-rumble:1.0-snapshot"
}

variable "app_port" {
  default = 9000
}

variable "app_count" {
  default = 1
}

variable "fargate_cpu" {
  default = "256"
}

variable "fargate_memory" {
  default = "512"
}

variable "lambda_memory_size" {
  default = 3008
}

variable "lambda_timeout" {
  default = 900
}

variable "domain" {
  default = "robotrumble.org"
}

variable "cloudflare_email" {}

variable "cloudflare_api_key" {}

variable "cloudflare_zone_id" {}

