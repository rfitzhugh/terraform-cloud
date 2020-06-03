output "nova-kms" {
  value = "${aws_kms_key.nova-kms.id}"
}

output "nova-bolt-sg-use1-c" {
  value = "${aws_security_group.nova-bolt-sg-use1-c.id}"
}