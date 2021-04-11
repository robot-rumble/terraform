resource "aws_sqs_queue" "battle_queue_in" {
  name                       = "battle-input-queue"
  visibility_timeout_seconds = var.lambda_timeout
}

resource "aws_sqs_queue" "battle_queue_out" {
  name = "battle-output-queue"
}

resource "aws_lambda_function" "battle_runner" {
  s3_bucket     = aws_s3_bucket.build.id
  s3_key        = aws_s3_bucket_object.lambda_build.key
  layers        = [aws_lambda_layer_version.wasmer_cache.arn]
  function_name = "battle-runner"
  runtime       = "provided"
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size
  handler       = "doesnt.matter"
  role          = aws_iam_role.lambda.arn
  environment {
    variables = {
      RUST_BACKTRACE       = 1
      BATTLE_QUEUE_OUT_URL = aws_sqs_queue.battle_queue_out.id
    }
  }
}

resource "aws_s3_bucket_object" "lambda_build" {
  bucket = aws_s3_bucket.build.bucket
  key    = "lambda.zip"
  source = "../../logic/lambda-dist/lambda.zip"
}

resource "aws_lambda_layer_version" "wasmer_cache" {
  layer_name          = "wasmer-cache"
  s3_bucket           = aws_s3_bucket.build.id
  s3_key              = aws_s3_bucket_object.wasmer_cache.key
  compatible_runtimes = ["provided"]
}

resource "aws_s3_bucket_object" "wasmer_cache" {
  bucket = aws_s3_bucket.build.bucket
  key    = "wasmer-cache.zip"
  source = "../../logic/lambda-dist/wasmer-cache.zip"
}

resource "aws_iam_policy" "lambda" {
  name = "lambda-policy"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:SendMessage",
                "sqs:GetQueueAttributes",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_iam_role" "lambda" {
  name = "lambda-iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_event_source_mapping" "battle_queue_in" {
  event_source_arn = aws_sqs_queue.battle_queue_in.arn
  function_name    = aws_lambda_function.battle_runner.arn
}

output "BATTLE_QUEUE_IN_URL" {
  value = aws_sqs_queue.battle_queue_in.id
}

output "BATTLE_QUEUE_OUT_URL" {
  value = aws_sqs_queue.battle_queue_out.id
}

output "LAYER_NAME" {
  value = aws_lambda_layer_version.wasmer_cache.layer_name
}
