variable "server_data_bucket_name" {
  type = string
}

variable "server_password_parameter_name" {
  type = string
}

variable "server_world_parameter_name" {
  type = string
}

variable "task_cpu" {
  type    = number
  default = 1024
}

variable "task_memory" {
  type    = number
  default = 4096
}

variable "server_name" {
  type = string
}
