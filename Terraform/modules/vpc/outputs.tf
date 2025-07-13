output "public_subnet_ids" {
  value = [aws_subnet.pub_sub1.id, aws_subnet.pub_sub2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.priv_sub1.id, aws_subnet.priv_sub2.id]
}