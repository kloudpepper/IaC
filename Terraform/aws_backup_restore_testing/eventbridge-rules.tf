# EventBridge rules for backup restore testing
module "eventbridge_default_rules" {
  source = "terraform-aws-modules/eventbridge/aws"

  create = true

  # Use default bus configuration
  create_bus          = false
  bus_name            = "default"
  append_rule_postfix = false

  create_log_delivery_source = false

  # Rules configuration
  create_rules = true
  rules = {
    "backup_restore_completed" = {
      name        = "backup_restore_completed"
      description = "Trigger Aurora restore validation on backup restore completion"
      event_pattern = jsonencode({
        source      = ["aws.backup"]
        detail-type = ["Restore Job State Change"]
        detail = {
          status       = ["COMPLETED"]
          resourceType = ["Aurora"]
          restoreTestingPlanArn = [{
            prefix = aws_backup_restore_testing_plan.aurora.arn
          }]
        }
      })
      enabled = true
    }
  }

  # Targets configuration
  create_targets = true
  targets = {
    "backup_restore_completed" = [
      {
        name            = "StartRestoreValidationStateMachine"
        arn             = module.backup_restore_validation_sfn.state_machine_arn
        attach_role_arn = true
      }
    ]
  }

  sfn_target_arns   = [module.backup_restore_validation_sfn.state_machine_arn]
  attach_sfn_policy = true
}
