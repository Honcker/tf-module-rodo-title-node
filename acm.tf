# resource "aws_acm_certificate" "lb-cert" {
#   domain_name       = var.lb_cert_domain_name
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }


# resource "aws_acm_certificate" "cloudfront-cert" {
#   domain_name       = var.cloudfront_cert_domain_name
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_acm_certificate" "public_wildcard" {
  domain_name = "*.${local.base_subdomain}"
  subject_alternative_names = [
    local.base_subdomain,
    "*.${local.base_subdomain}"
  ]
  validation_method = "DNS"
  tags              = local.default__tags
}

resource "aws_acm_certificate_validation" "public_wildcard" {
  certificate_arn = aws_acm_certificate.public_wildcard.arn
}


resource "aws_acm_certificate" "public_wildcard_cloudfront" {
  domain_name = "*.${local.base_subdomain}"
  subject_alternative_names = [
    local.base_subdomain,
    "*.${local.base_subdomain}"
  ]
  validation_method = "DNS"

  provider = aws.us-east-1
  tags     = local.default__tags

}

resource "aws_acm_certificate_validation" "public_wildcard_cloudfront" {
  certificate_arn = aws_acm_certificate.public_wildcard_cloudfront.arn

  provider = aws.us-east-1
}
