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

variable "rds_allocated_storage" {
  default = 10
}

variable "rds_max_allocated_storage" {
  default = 20
}

variable "rds_instance_class" {
  default = "db.t2.micro"
}

variable "rds_name" {
  default = "robot"
}

variable "rds_username" {
  default = "robot"
}

variable "rds_password" {}

variable "lambda_memory_size" {
  default = 128
}

variable "lambda_timeout" {
  default = 10
}

variable "secret_key" {}
