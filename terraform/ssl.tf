
resource "aws_acm_certificate" "cert" {
  provider = aws.us-east

  domain_name = local.domain_name
  validation_method = "DNS"

  tags = var.tags
}


resource "aws_route53_record" "cert_validation" {
  provider = aws.us-east

  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.domain.id
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider = aws.us-east

  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

#aws_acm_certificate_validation.cert.certificate_arn