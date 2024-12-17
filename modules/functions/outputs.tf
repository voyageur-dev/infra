output "invoke_arn" {
  description = "The invoke arn of the lambda function"
  value = aws_lambda_function.function.invoke_arn
}