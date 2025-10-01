#cloud-config
runcmd:
  - [ bash, -lc, "apt-get update && apt-get install -y nodejs npm awscli unzip" ]
  - [ bash, -lc, "mkdir -p /opt/${app_name} && cd /opt/${app_name}" ]
  - [ bash, -lc, "aws s3 cp s3://${app_bucket}/${app_name}.zip /tmp/${app_name}.zip --region ${aws_region}" ]
  - [ bash, -lc, "unzip -o /tmp/${app_name}.zip -d /opt/${app_name}" ]
  - [ bash, -lc, "cd /opt/${app_name} && npm install --production" ]
  - [ bash, -lc, "export DB_HOST=$(aws ssm get-parameter --name '/${app_name}/DB_HOST' --region ${aws_region} --query Parameter.Value --output text)" ]
  - [ bash, -lc, "export DB_USER=$(aws ssm get-parameter --name '/${app_name}/DB_USER' --region ${aws_region} --query Parameter.Value --output text)" ]
  - [ bash, -lc, "export DB_PASS=$(aws ssm get-parameter --name '/${app_name}/DB_PASS' --with-decryption --region ${aws_region} --query Parameter.Value --output text)" ]
  - [ bash, -lc, "node /opt/${app_name}/migrate_and_start.js &" ]
packages:
  - unzip
