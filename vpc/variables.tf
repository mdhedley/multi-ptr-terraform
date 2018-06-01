//region for the subnets
variable "region" {
  type = "string"
}

// CIDR for the edge nodes
variable "edge-cidr" {
  type = "string"
}

// CIDR for the sending nodes
variable "send-cidr" {
  type = "string"
}
