output "arn" {
  description = "Arn of lambda function"
  #value = toset([
  #  for inst in aws_lambda_function.lambda : inst.invoke_arn
  #])
  value = tomap({
      for inst in aws_lambda_function.lambda : inst.function_name => inst.invoke_arn
  })
}

output "function_name" {
  description = "Lambda function name"
  #value = toset([
  #  for inst in aws_lambda_function.lambda : inst.function_name
  #])
  value = tomap({
      for inst in aws_lambda_function.lambda : inst.function_name => inst.function_name
  })
  
}