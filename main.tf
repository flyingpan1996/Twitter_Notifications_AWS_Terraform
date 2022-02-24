
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider


provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Configure Ubuntu EC2 Instance

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"

  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  key_name      = "twitter"

}

# Configure Kinesis Stream

resource "aws_kinesis_stream" "twitter_stream" {
  name             = "twitter-data-stream"
  shard_count      = 1
  retention_period = 24
}



# Configure the S3 Bucket


resource "aws_s3_bucket" "blog" {
  bucket = var.bucket_name
  acl    = "private"
}


# Configure the SNS Topic


resource "aws_sns_topic" "user_updates" {
  name = "tweet-notification"
}

# Configure SNS Policy


resource "aws_sns_topic_policy" "sns_policy" {
  arn = aws_sns_topic.user_updates.arn


  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__sns_policy_ID"

  statement {
    actions = [
      "SNS:Publish",
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:s3:::aws_s3_bucket"
      ]
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.user_updates.arn,
    ]

  }
}

# Configure SNS Topic Subscription

resource "aws_sns_topic_subscription" "topic_subscription" {

  topic_arn = aws_sns_topic.user_updates.arn

  protocol = "email"

  endpoint = var.email_address

}

# Configure Bucket Event Notification

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.blog.id

  topic {
    topic_arn = aws_sns_topic.user_updates.arn
    events    = ["s3:ObjectCreated:*"]
  }
}