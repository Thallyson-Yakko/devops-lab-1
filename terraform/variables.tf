variable "region" {
    type = string
    default = "us-east-1"
  
}

variable "access_key" {
    type = string
    default = "test"
  
}

variable "secret_key" {
    type = string
    default = "test"
  
}

variable "bucket" {
    type = string
    default = "test-ministack"
  
}

variable "aws_sqs_queue" {
    type = string
    default = "test-sqs"
}