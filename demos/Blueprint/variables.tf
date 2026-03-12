variable "region" {
  description = "Región de AWS donde se crearán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "allowed_ssh_cidr" {
  default = "0.0.0.0/0"
}

variable "ami_id" {
  description = "ID de la imagen base para la EC2"
  type        = string
  default     = "ami-0b6c6ebed2801a5cb" // ubuntu 24.04
}

variable "instance_type" {
  description = "Tamaño de la instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Nombre del proyecto, se usa como prefijo en los recursos"
  type        = string
  default     = "blueprint"
}

variable "expediente" {
  description = "Número de expediente, se usa para que el nombre del bucket sea único"
  type        = string
}
