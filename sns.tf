### AWS SNS
resource "aws_sns_topic" "gizmos_sns_topic" {
  name         = "gizmos-aws-sign-in"
  display_name = "Gizmos login"
}

resource "aws_sns_topic_policy" "gizmos_topic_policy" {
  arn    = aws_sns_topic.gizmos_sns_topic.arn
  policy = data.aws_iam_policy_document.gizmos_topic_policy.json
}

data "aws_iam_policy_document" "gizmos_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.gizmos_sns_topic.arn]
  }
}

resource "aws_sns_topic_subscription" "gizmos_sqs_subscription" {
  topic_arn = aws_sns_topic.gizmos_sns_topic.arn
  protocol  = "email"
  endpoint  = var.subscription_email
}
