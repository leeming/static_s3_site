data "aws_route53_zone" "domain" {
  zone_id         = var.dns_zone_id
  private_zone = false
}

locals {
    domain_name = trimsuffix(data.aws_route53_zone.domain.name, ".")
}

resource "aws_route53_record" "www_site" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name = local.domain_name
  type = "A"
  alias {
    name = aws_cloudfront_distribution.website_cdn.domain_name
    zone_id  = aws_cloudfront_distribution.website_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}