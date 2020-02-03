# Mix of examples from:
# - https://www.intricatecloud.io/2018/04/creating-your-serverless-website-in-terraform-part-2/
# - https://github.com/conortm/terraform-aws-s3-static-website/blob/master/main.tf
# - https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "cloudfront origin access identity"
}

locals {
  s3_origin_id = "cloudfront-distribution-origin-${local.domain_name}.s3.amazonaws.com/"
}

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled      = true
  price_class  = "PriceClass_100"
  http_version = "http1.1"
  aliases = ["${local.domain_name}"]

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }

    # custom_origin_config {
    #   http_port               = 80
    #   https_port              = 443
    #   origin_protocol_policy  = "http-only"
    #   origin_ssl_protocols    = ["TLSv1.2"] # ["TLSv1.2", "TLSv1.3"] # CF apparently doesn't support 1.3 yet - 01/2020
    # }
  }

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    min_ttl          = "0"
    default_ttl      = "300"                                              //3600
    max_ttl          = "1200"                                             //86400

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method       = "sni-only"
  }

  tags = var.tags
}