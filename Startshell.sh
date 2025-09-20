#!/bin/bash
# Update & install Apache on Ubuntu
apt-get update -y
apt-get install -y apache2 curl

# Enable and start Apache
systemctl enable apache2
systemctl restart apache2

# Get metadata token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Fetch instance metadata using IMDSv2
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-type)
AVAILABILITY_ZONE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "N/A")
REGION=${AVAILABILITY_ZONE%?}
TIMESTAMP=$(date)

# Create a nice index.html
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>My EC2 Web Server</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: linear-gradient(to right, #1d4350, #a43931);
      color: #fff;
      text-align: center;
      padding: 50px;
    }
    h1 {
      font-size: 3em;
      margin-bottom: 20px;
    }
    .info {
      background: rgba(0,0,0,0.5);
      border-radius: 12px;
      padding: 20px;
      display: inline-block;
      text-align: left;
    }
    p {
      font-size: 1.2em;
      margin: 10px 0;
    }
  </style>
</head>
<body>
  <h1>Welcome to My EC2 Web Server A</h1>
  <div class="info">
    <p><b>Instance ID:</b> $INSTANCE_ID</p>
    <p><b>Instance Type:</b> $INSTANCE_TYPE</p>
    <p><b>Availability Zone:</b> $AVAILABILITY_ZONE</p>
    <p><b>Region:</b> $REGION</p>
    <p><b>Private IP:</b> $PRIVATE_IP</p>
    <p><b>Public IP:</b> $PUBLIC_IP</p>
    <p><b>Timestamp:</b> $TIMESTAMP</p>
  </div>
</body>
</html>
EOF
