#! /bin/bash

# Create an SSH key if one doesn't already exist
if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
  ssh-keygen
fi

# Login to your taget azure subscription
az login

# Deploy the infrastructure
terraform apply