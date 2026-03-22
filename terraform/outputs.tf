output "ec2_public_ip" {
  description = "Public IP of the Airflow EC2 instance"
  value       = aws_instance.airflow.public_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 output bucket"
  value       = aws_s3_bucket.pipeline_output.bucket
}