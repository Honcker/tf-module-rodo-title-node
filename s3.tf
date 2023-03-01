resource "aws_s3_bucket" "rodo-title-s3-web" {
  for_each = local.entities_to_maintain
  bucket   = local.node_entities_json.node_entity_map[each.key].s3bucket

  # force_destroy = local.is_ephemeral_env
  # note: if a bucket is destroyed, you may be unable to create a new one with the same name for hours ...

  tags = local.default__tags
}

resource "aws_s3_bucket_lifecycle_configuration" "rodo-title-s3-web-lifecycle-config" {
  for_each = local.is_ephemeral_env ? local.entities_to_maintain : toset([])
  bucket   = aws_s3_bucket.rodo-title-s3-web[each.key].bucket

  # This is in place to control costs in case 
  #   buckets are not destroyed when they are no longer used for development
  #   -- there is no charge for empty buckets

  rule {
    id = "expire-ephemeral-after-30-days"

    expiration {
      days = 30
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "rodo-title-s3-web" {
  for_each = local.entities_to_maintain
  bucket   = aws_s3_bucket.rodo-title-s3-web[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "rodo-title-s3-web" {
  for_each = local.entities_to_maintain
  bucket   = aws_s3_bucket.rodo-title-s3-web[each.key].bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

data "aws_iam_policy_document" "rodo-title-s3-web-bucket-policy" {

  for_each = local.entities_to_maintain
  statement {
    sid     = "AllowSSLrequestsOnly"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.rodo-title-s3-web[each.key].arn,
      "${aws_s3_bucket.rodo-title-s3-web[each.key].arn}/*",
    ]

    effect = "Deny"

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  # Include this only if cloudfront is deployed for bucket
  dynamic "statement" {
    for_each = contains(local.entities_to_maintain, each.key) ? [each.key] : []

    content {
      sid     = "AllowCFOriginAccess"
      actions = ["s3:GetObject"]
      resources = [
        aws_s3_bucket.rodo-title-s3-web[each.key].arn,
        "${aws_s3_bucket.rodo-title-s3-web[each.key].arn}/*",
      ]
      principals {
        type        = "AWS"
        identifiers = [aws_cloudfront_origin_access_identity.rodo-title-s3-web[each.key].iam_arn]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "rodo-title-s3-web" {
  for_each = local.entities_to_maintain
  bucket   = aws_s3_bucket.rodo-title-s3-web[each.key].id
  policy   = data.aws_iam_policy_document.rodo-title-s3-web-bucket-policy[each.key].json
}


resource "aws_s3_bucket_acl" "rodo-title-s3-web" {
  for_each = local.entities_to_maintain
  bucket   = aws_s3_bucket.rodo-title-s3-web[each.key].id
  acl      = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "rodo-title-s3-web" {
  for_each = local.entities_to_maintain
  bucket   = aws_s3_bucket.rodo-title-s3-web[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket" "title-automation" {
  bucket = "rodo-title-${local.node_slug}-start-stop-automation"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "title-automation" {
  bucket = aws_s3_bucket.title-automation.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.title-automation.arn
    }
  }
}

resource "aws_s3_bucket_acl" "title-automation" {
  bucket = aws_s3_bucket.title-automation.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "title-automation" {
  bucket = aws_s3_bucket.title-automation.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_object" "title-automation" {
  for_each = fileset("${path.module}/automation/", "*")
  bucket   = aws_s3_bucket.title-automation.id

  key    = each.value
  source = "${path.module}/automation/${each.value}"

  etag = filemd5("${path.module}/automation/${each.value}")
}
