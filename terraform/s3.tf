resource "aws_s3_bucket" "logs" {
  bucket = "${local.domain_name}-logs"
  acl = "log-delivery-write"

  tags = var.tags
}

resource "aws_s3_bucket" "website" {
  bucket = local.domain_name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  logging {
    target_bucket = aws_s3_bucket.logs.bucket
    target_prefix = "${local.domain_name}/"
  }
  tags = var.tags
}

data "aws_iam_policy_document" "public_read" {
  statement {
    sid       = "PublicRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.public_read.json
}


resource "aws_s3_bucket_object" "index" {
    bucket = aws_s3_bucket.website.id
    key = "index.html"
    source = "index.html"
    content_type = "text/html"
}
resource "aws_s3_bucket_object" "error" {
    bucket = aws_s3_bucket.website.id
    key = "error.html"
    source = "error.html"
    content_type = "text/html"
}
