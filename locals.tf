locals {
  ecs_secrets = var.enable_secret_assigned_to_single_key ? [
    {
      name      = coalesce(one(var.key_names), upper(replace(replace(var.name,"/[^a-zA-Z\\d\\-_:]/","*"),"-","_")))
      valueFrom = aws_secretsmanager_secret.ecs.arn
    }
  ] : [
    for key_name in var.key_names :{
      name      = key_name
      valueFrom = "${aws_secretsmanager_secret.ecs.arn}:${key_name}::"
    }
  ]
}
