output "ssh_keypair_publickey" {
  value = "${element(concat(tls_private_key.keypair.*.public_key_openssh, list("")), 0)}"
}