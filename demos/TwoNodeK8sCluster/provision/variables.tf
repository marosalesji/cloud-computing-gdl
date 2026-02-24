variable "region" {
  default = "us-east-1"
}

variable "allowed_ssh_cidr" {
  default = "0.0.0.0/0"
}

variable "k3s_token" {
  description = "Token compartido entre controller y worker"
  default     = "super-secret-k3s-token"
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "aws_session_token" {
  type      = string
  sensitive = true
  default   = ""
}
