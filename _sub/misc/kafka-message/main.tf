locals {

  message_map = {
    "version"         = var.message_version
    "eventName"       = var.event_name
    "x-correlationId" = var.correlation_id
    "x-sender"        = var.sender
    "payload"         = jsondecode(var.payload)
  }

  message_json = jsonencode(local.message_map)

}

resource "null_resource" "message" {
  triggers = {
    message_checksum = sha256(local.message_json)
  }

  provisioner "local-exec" {
    command = "if [ \"${var.publish}\" = \"true\" ]; then echo '${var.key}:${local.message_json}' | ${var.kafka_cli} -P -b ${var.broker} -t ${var.topic} -K: -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN -X sasl.username=${var.username} -X sasl.password=${var.password} -X api.version.request=true -X ssl.ca.location=/etc/ssl/certs/ca-certificates.crt; fi"
  }
}
