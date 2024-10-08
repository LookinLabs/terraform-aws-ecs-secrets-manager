# terraform-aws-ecs-secrets-manager

Terraform module to create a SecretManager secret and generate secrets definition to be injected in the ECS Container definition.

This module uses the recommended way of passing sensitive data from SecretManager to ECS Task without hardcoding any sensitive values in the ECS Container definition.

## Usage

### Passing specific keys to ECS task definition
```hcl
module "secrets" {
  source  = "exlabs/ecs-secrets-manager/aws"
  # We recommend pinning every module to a specific version
  version = "1.1.0"
  name    = "data-pipeline-secrets"

  ecs_task_execution_roles = [
    "ecs-task-execution-role1",
    "ecs-task-execution-role2"
  ]

  key_names = [
    "STRIPE_PUBLIC_KEY",
    "STRIPE_SECRET_KEY",
    "STRIPE_WEBHOOK_SECRET"
  ]
}

resource "aws_ecs_task_definition" "data_pipeline" {
  #...

  container_definitions = jsonencode([
    {
      secrets = module.secrets.ecs_secrets,
      #...
    }
  ])
}
```

### Passing the whole AWS Secret Manager secret to the ECS task as a single variable
```hcl
module "secrets" {
  source  = "exlabs/ecs-secrets-manager/aws"
  # We recommend pinning every module to a specific version
  version = "1.1.0"
  name    = "data-pipeline-secrets"

  enable_secret_assigned_to_single_key = true

  ecs_task_execution_roles = [
    "ecs-task-execution-role1",
    "ecs-task-execution-role2"
  ]

  # You can define your own key or leave it default then the key name is built based on the secret name
  key_names = [
    "YOUR_OWN_KEY"
  ]
}

resource "aws_ecs_task_definition" "data_pipeline" {
  #...

  container_definitions = jsonencode([
    {
      secrets = module.secrets.ecs_secrets,
      #...
    }
  ])
}
```

After `terraform apply` you have to go to the AWS Console SecretsManager dashboard, select created secret and set values by creating a key-value pair for each defined key name.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.read_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_secretsmanager_secret.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [random_id.policy_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | AWS SecretsManager secret description | `string` | `null` | no |
| <a name="input_ecs_task_execution_roles"></a> [ecs\_task\_execution\_roles](#input\_ecs\_task\_execution\_roles) | ECS task execution role names that should be allowed to read secrets | `list(string)` | `[]` | no |
| <a name="input_enable_secret_assigned_to_single_key"></a> [enable\_secret\_assigned\_to\_single\_key](#input\_enable\_secret\_assigned\_to\_single\_key) | Enables returning the whole secret as a single key-value pair | `bool` | `false` | no |
| <a name="input_key_names"></a> [key\_names](#input\_key\_names) | Secret names that will be injected as env variables | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | AWS SecretsManager secret name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_secrets"></a> [ecs\_secrets](#output\_ecs\_secrets) | Secrets description to be injected in the ECS Container definition. |
| <a name="output_secretsmanager_secret_arn"></a> [secretsmanager\_secret\_arn](#output\_secretsmanager\_secret\_arn) | AWS SecretsManager secret ARN |
<!-- END_TF_DOCS -->
