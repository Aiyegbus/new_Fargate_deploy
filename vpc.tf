# VPC
data "aws_availability_zones" "fargate_azs" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
resource "aws_vpc" "fargate_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
}

resource "aws_internet_gateway" "fargate_gw" {
  vpc_id = aws_vpc.fargate_vpc.id
}

# Subnets
resource "aws_subnet" "fargate_subnets" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.fargate_vpc.id
  cidr_block              = element(["172.16.32.0/20", "172.16.64.0/20", "172.16.96.0/20", "172.16.128.0/20"], count.index % 4)
  availability_zone       = element(data.aws_availability_zones.fargate_azs.names, count.index % length(data.aws_availability_zones.fargate_azs.names))
  map_public_ip_on_launch = true
}

resource "aws_route_table" "fargate_rt" {
  vpc_id = aws_vpc.fargate_vpc.id

}

resource "aws_route" "fargate_route" {
  route_table_id         = aws_route_table.fargate_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fargate_gw.id

}

resource "aws_route_table_association" "fargate_rt_ass" {
  route_table_id = aws_route_table.fargate_rt.id
  subnet_id      = element(aws_subnet.fargate_subnets.*.id, count.index)
  count          = var.subnet_count
}
