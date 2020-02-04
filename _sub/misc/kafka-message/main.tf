locals {
  message = <<EOF
{"version":"${var.message_version}","eventName":"${var.event_name}","x-correlationId":"${var.correlation_id}","x-sender":"${var.sender}","payload":${var.payload}}
EOF

}

resource "null_resource" "message" {
  triggers = {
    message_checksum = sha256(local.message)
  }

  count = var.publish

  provisioner "local-exec" {
    command = "echo '${var.key}:${local.message}' | kafkacat -P -b ${var.broker} -t ${var.topic} -K: -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN -X sasl.username=${var.username} -X sasl.password=${var.password} -X api.version.request=true -X ssl.ca.location=/etc/ssl/certs/ca-certificates.crt"
  }
}

