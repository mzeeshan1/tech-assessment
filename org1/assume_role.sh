#!/bin/bash

# Ensure an argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <role-name>"
    exit 1
fi

# Get the role name from the command-line argument
role_name=$1

awsume $1

# Assume the role
response=$(aws sts assume-role --role-arn "arn:aws:iam::533266993905:role/$role_name" --role-session-name "$role_name" 2>&1)

# Debugging the response
echo "Response: $response"

# Check if the assume-role command was successful
if [ $? -ne 0 ]; then
    echo "Error assuming role: $response"
    exit 1
fi

# Extract and export credentials
export AWS_ACCESS_KEY_ID=$(echo "$response" | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(echo "$response" | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(echo "$response" | jq -r ".Credentials.SessionToken")

# Debugging the exported variables
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
echo "AWS_SESSION_TOKEN: $AWS_SESSION_TOKEN"

# Confirm successful export of credentials
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
    echo "Failed to export credentials. Check response and parsing."
    exit 2
fi

echo "AWS credentials set for role: $role_name"
