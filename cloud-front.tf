locals {
  s3_origin_id = { for cfe in local.entities_to_maintain : cfe => "${local.node_slug}-rodo-title-${local.cloudfronted_entities_names[cfe]}-s3-origin" }
}

resource "aws_cloudfront_origin_access_identity" "rodo-title-s3-web" {
  for_each = local.entities_to_maintain
  comment  = "rodo title cloud front for web entity ${each.key}"
}

resource "aws_cloudfront_distribution" "rodo-title-s3-web-distribution" {
  for_each = local.entities_to_maintain

  origin {
    domain_name = aws_s3_bucket.rodo-title-s3-web[each.key].bucket_regional_domain_name
    origin_id   = local.s3_origin_id[each.key]


    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.rodo-title-s3-web[each.key].cloudfront_access_identity_path
    }
  }

  aliases = [local.ui_domain_names[each.key]]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  ordered_cache_behavior {
    path_pattern     = "*.html"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id[each.key]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 25
    max_ttl                = 50
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id[each.key]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.public_wildcard_cloudfront.arn
    ssl_support_method  = "sni-only"
    # minimum_protocol_version = "TLSv1"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.default__tags

  depends_on = [
    aws_acm_certificate_validation.public_wildcard_cloudfront
  ]
}