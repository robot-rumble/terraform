variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "docker.pkg.github.com/robot-rumble/backend/robot-rumble:1.0-snapshot"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 9000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
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

variable "lambda_memory_size" {
  default = 128
}

variable "lambda_timeout" {
  default = 60
}

variable "rds_password" {}
variable "secret_key" {}
