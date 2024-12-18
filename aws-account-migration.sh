#!/bin/bash

# AWS Profiles
SOURCE_PROFILE="source-profile"
TARGET_PROFILE="target-profile"

# AWS Region
AWS_REGION="us-east-1"

# Pattern to filter secrets (optional)
SECRET_NAME_PATTERN="my-pattern" # Replace with your desired pattern or leave empty

# Fetch the list of secrets from the source account
echo "Fetching secrets from the source account..."
if [[ -z "$SECRET_NAME_PATTERN" ]]; then
    SECRETS=$(aws secretsmanager list-secrets --profile $SOURCE_PROFILE --region $AWS_REGION --query 'SecretList[].Name' --output text)
else
    SECRETS=$(aws secretsmanager list-secrets --profile $SOURCE_PROFILE --region $AWS_REGION --query "SecretList[?contains(Name, \`$SECRET_NAME_PATTERN\`)].Name" --output text)
fi

# Check if any secrets match the pattern
if [[ -z "$SECRETS" ]]; then
    echo "No secrets found matching pattern: $SECRET_NAME_PATTERN"
    exit 0
fi

# Iterate over secrets and migrate each one
for SECRET_NAME in $SECRETS; do
  echo "Migrating secret: $SECRET_NAME"

  # Get the secret value from the source account
  SECRET_VALUE=$(aws secretsmanager get-secret-value --profile $SOURCE_PROFILE --region $AWS_REGION --secret-id "$SECRET_NAME" --query 'SecretString' --output text)

  # Create the secret in the target account
  aws secretsmanager create-secret \
    --profile $TARGET_PROFILE \
    --region $AWS_REGION \
    --name "$SECRET_NAME" \
    --secret-string "$SECRET_VALUE"

  echo "Secret migrated: $SECRET_NAME"
done

echo "Migration complete!"