#!/bin/bash

#1 - Subindo docker compose

docker build -t app_sqs:latest .

sleep 2m

docker compose up -d
sleep 50s

# 2 - Terraform Init

cd terraform && terraform init


# 3 - Terraform apply

terraform apply -auto-approve