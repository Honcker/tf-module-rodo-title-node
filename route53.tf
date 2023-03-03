
resource "aws_route53_record" "ui" {
  for_each = local.entities_to_maintain

  zone_id         = data.aws_route53_zone.public.zone_id
  name            = local.ui_domain_names[each.key]
  type            = "CNAME"
  ttl             = 300
  records         = [aws_cloudfront_distribution.rodo-title-s3-web-distribution[each.key].domain_name]
  allow_overwrite = true

  provider = aws.dns
}

resource "aws_route53_record" "proxy" {
  zone_id         = data.aws_route53_zone.public.zone_id
  name            = local.proxy_domain_name
  type            = "CNAME"
  ttl             = 300
  records         = [aws_lb.rodo-title-lb.dns_name]
  allow_overwrite = true

  provider = aws.dns
}

resource "aws_route53_record" "corda_node" {
  zone_id         = data.aws_route53_zone.public.zone_id
  name            = local.corda_node_domain_name
  type            = "CNAME"
  ttl             = 300
  records         = [aws_lb.corda-lb.dns_name]
  allow_overwrite = true

  provider = aws.dns
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for v in aws_acm_certificate.public_wildcard.domain_validation_options : v.domain_name => {
      name   = v.resource_record_name
      record = v.resource_record_value
      type   = v.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.public.zone_id
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  allow_overwrite = true

  provider = aws.dns
}

resource "aws_route53_record" "cert_validation_cloudfront" {
  for_each = {
    for v in aws_acm_certificate.public_wildcard_cloudfront.domain_validation_options : v.domain_name => {
      name   = v.resource_record_name
      record = v.resource_record_value
      type   = v.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.public.zone_id
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  allow_overwrite = true

  provider = aws.dns
}
