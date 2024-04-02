#!/bin/bash

# Function to fetch metadata attribute
get_metadata_attribute() {
  local attribute="$1"
  curl -sS "http://metadata.google.internal/computeMetadata/v1/instance/attributes/$attribute" -H "Metadata-Flavor: Google"
}

# Fetch database configuration from instance metadata
DB_NAME=$(get_metadata_attribute "db_name")
DB_USER=$(get_metadata_attribute "db_user")
DB_PASSWORD=$(get_metadata_attribute "db_password")
DB_HOST=$(get_metadata_attribute "db_host")

# Path to your application environment file
ENV_FILE="/opt/csye6225/.env"

# Configure your application with these values
cat > "$ENV_FILE" << EOF
DB_DIALECT="postgres"
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=$DB_HOST
GCLOUD_PROJECT_ID="csye-6225-ns-cloud-dev"
EOF



# sudo tee .env <<EOL
# PORT=5432
# DB_HOST="localhost"
# DB_NAME="health_check_db"
# DB_DIALECT="postgres"
# DB_USER="postgres"
# DB_PASSWORD="root"
# EOL

if cat "$ENV_FILE"; then
  echo "Application configuration updated successfully."
  # Replace with your actual service restart command or systemd unit reload if necessary
  sudo systemctl restart webapp.service
else
  echo "Failed to update application configuration."
fi
