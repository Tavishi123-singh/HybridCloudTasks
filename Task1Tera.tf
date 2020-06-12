provider "aws" {
  region     = "us-east-1"
  profile = "myprofile"
}

resource "tls_private_key" "prikey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "OSkey" {
  key_name = "OS-key"
  public_key = tls_private_key.prikey.public_key_openssh
}

resource "aws_security_group" "newgrp" {
  name        = "MySecurityGroup"
  description = "Allow HTTP inbound traffic"
  
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}

resource "aws_security_group_rule" "secgrprule1" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.newgrp.id
}

resource "aws_security_group_rule" "secgrprule2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.newgrp.id
}

resource "aws_instance" "myin" {
  ami           = "ami-09d95fab7fff3776c"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.OSkey.key_name
  security_groups = ["MySecurityGroup"] 

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.prikey.private_key_pem
    host     = aws_instance.myin.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "MyFirstOS"
  }
}

output "outip"{
  value=aws_instance.myin.public_ip
}

resource "null_resource" "local1" {

  provisioner "local-exec" {
    command = "echo ${aws_instance.myin.public_ip} > publicip.txt"
  }
}

resource "null_resource" "local2" {
  depends_on = [
    null_resource.remote1,aws_cloudfront_distribution.s3_distribution
  ]
  provisioner "local-exec" {
    command = "start chrome ${aws_instance.myin.public_ip}"
  }
}

output "outaz"{
  value=aws_instance.myin.availability_zone
}

resource "aws_ebs_volume" "ebs_vol" {
  availability_zone = aws_instance.myin.availability_zone
  size              = 1

  tags = {
    Name = "MyVol"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_vol.id
  instance_id = aws_instance.myin.id
  force_detach = true
}

resource "null_resource" "remote1" {
  depends_on = [
    aws_volume_attachment.ebs_att,
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.prikey.private_key_pem
    host     = aws_instance.myin.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html/",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/Tavishi123-singh/MultiCloud.git /var/www/html/",
    ]
  }
}

resource "aws_s3_bucket" "buck" {
  bucket = "my-task1-image-bucket"
  force_destroy = true

  versioning {
    enabled = true
  }
  grant {
    type        = "Group"
    permissions = ["READ"]
    uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
  }
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "buck_obj" {
  bucket = "my-task1-image-bucket"
  key    = "AWS.png"
  source = "C:/Users/Tavishi/Downloads/AWS.png"
  etag = filemd5("C:/Users/Tavishi/Downloads/AWS.png")
  acl = "public-read"
 
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [
    null_resource.remote1
  ]
  origin {
    domain_name = aws_s3_bucket.buck.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "The image of AWS"
  default_root_object = "AWS.png"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.prikey.private_key_pem
    host     = aws_instance.myin.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su << EOF",
      "echo \"<img src='http://${self.domain_name}/${aws_s3_bucket_object.buck_obj.key}' height='200px' width='200px'>\" >> /var/www/html/index.html",
      "EOF",
    ]
  }
}
