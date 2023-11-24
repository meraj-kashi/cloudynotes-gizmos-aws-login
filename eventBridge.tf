### AWS EventBridge
resource "aws_cloudwatch_event_rule" "gizmos_event_rule" {
  name        = "gizmos-aws-sign-in"
  description = "Capture each AWS Console Sign In"

  event_pattern = <<PATTERN
  {
  "source": ["aws.signin"],
  "detail-type": ["AWS Console Sign In via CloudTrail"],
  "detail": {
    "eventSource": ["signin.amazonaws.com"],
    "eventName": ["ConsoleLogin"]
    }
  }
  PATTERN
}

resource "aws_cloudwatch_event_target" "gizmos_event_target" {
  rule      = aws_cloudwatch_event_rule.gizmos_event_rule.name
  target_id = "gizmosLoginSNS"
  arn       = aws_sns_topic.gizmos_sns_topic.arn

  input_transformer {
    input_paths = {
      aws_account = "$.detail.awsRegion",
      time        = "$.time",
      user        = "$.detail.userIdentity.accountId"
    }
    input_template = <<EOF
        "Warning! Successfully loggin to <aws_account> at <time> with user: <user>!"
    EOF
  }
}
