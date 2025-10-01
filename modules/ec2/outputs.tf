output "bucket_name" { value = aws_s3_bucket.app_bucket.bucket }
output "instance_id" { value = aws_instance.web.id }
output "instance_private_ip" { value = aws_instance.web.private_ip }
output "instance_profile_name" { value = aws_iam_instance_profile.ec2_profile.name }
