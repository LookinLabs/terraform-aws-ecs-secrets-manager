resource "aws_secretsmanager_secret" "ecs" {
  name        = var.name
  description = var.description
}

resource "random_id" "policy_suffix" {
  byte_length = 8
}

resource "aws_iam_policy" "read_secrets" {
  name        = "SecretsManagerPolicyForECSTaskExecutionRole-${random_id.policy_suffix.hex}"
  description = "Access rights to SecretsManager Secret created by terraform-aws-ecs-secrets-manager module"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.ecs.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets" {
  for_each   = toset(var.ecs_task_execution_roles)
  role       = each.value
  policy_arn = aws_iam_policy.read_secrets.arn
}
