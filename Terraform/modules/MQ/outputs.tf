output "MQEnpointAddr" {
  description = "Endpoint SSL ApacheMQ"
  value       = try(aws_mq_broker.ApacheMQ.instances[0].endpoints[0], "")
}