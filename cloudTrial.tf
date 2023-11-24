### Enable AWS CloudTrial
resource "aws_cloudtrail" "gizmos" {
  depends_on = [aws_s3_bucket_policy.gizmos]

  name                          = "cloudynotes-gizmos-trial"
  s3_bucket_name                = aws_s3_bucket.gizmos.id
  include_global_service_events = true
  is_multi_region_trail         = true
}

resource "aws_s3_bucket" "gizmos" {
  bucket        = "cloudynotes-gizmos-trial"
  force_destroy = true
}

data "aws_iam_policy_document" "gizmos" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.gizmos.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.gizmos.partition}:cloudtrail:${data.aws_region.gizmos.name}:${data.aws_caller_identity.gizmos.account_id}:trail/cloudynotes-gizmos-trial"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.gizmos.arn}/AWSLogs/${data.aws_caller_identity.gizmos.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.gizmos.partition}:cloudtrail:${data.aws_region.gizmos.name}:${data.aws_caller_identity.gizmos.account_id}:trail/cloudynotes-gizmos-trial"]
    }
  }
}

resource "aws_s3_bucket_policy" "gizmos" {
  bucket = aws_s3_bucket.gizmos.id
  policy = data.aws_iam_policy_document.gizmos.json
}

data "aws_caller_identity" "gizmos" {}

data "aws_partition" "gizmos" {}

data "aws_region" "gizmos" {}
