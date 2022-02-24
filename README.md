# Twitter_Notifications_AWS_Terraform

Hosted a python script on an Ubuntu EC2 Server to capture specific tweets from Twitter using Tweepy API.

Send the captured data to S3 by utilizing Kinesis Data Stream and Kinesis Firehose.

Enabled S3 Event notification to trigger an SNS Topic to receive notification in my email.

Deployed entire infrastructure as a code using Hashicorp Terraform.
