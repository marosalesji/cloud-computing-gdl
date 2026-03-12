output "server_public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_instance.server.public_ip
}

output "server_instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.server.id
}

output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.storage.bucket
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.storage.arn
}

output "private_key_pem" {
  description = "Llave privada para conectarse a la EC2 por SSH"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true // no se va a imprimir
}
