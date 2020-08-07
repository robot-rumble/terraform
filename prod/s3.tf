resource "aws_s3_bucket" "build" {
  bucket = "rr-build-files"
  acl    = "private"
}

resource "aws_s3_bucket" "public" {
  bucket = "rr-public-assets"
  acl    = "private"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public.id

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Principal": {
        "CanonicalUser": "${aws_cloudfront_origin_access_identity.default.s3_canonical_user_id}"
      },
      "Action": "s3:GetObject",
      "Resource":["${aws_s3_bucket.public.arn}/*"]
    }
  ]
}
EOF
}


locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
      headers = [
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
        "Origin"
      ]
    }
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  origin {
    domain_name = aws_s3_bucket.public.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource aws_cloudfront_origin_access_identity "default" {}

output "S3_BUCKET_BUILD" {
  value = aws_s3_bucket.build.id
}

output "S3_BUCKET_PUBLIC" {
  value = aws_s3_bucket.public.id
}

output "CLOUDFRONT_URL" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
