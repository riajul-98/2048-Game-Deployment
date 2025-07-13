variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block"
}

variable "subnet_cidr_blocks" {
  type        = list(string)
  description = "List of subnet cidr blocks"
}

variable "route_table_cidr" {
  type        = string
  description = "CIDR block for route table"
}

variable "instance_types" {
  type = list(string)
}