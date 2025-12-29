#!/bin/sh

# Replace environment variables in config.json
# We use a temp file to avoid issues with reading and writing to the same file
# Using sed for minimal dependency footprint (no envsubst needed)

if [ -f /usr/share/nginx/html/assets/config.json ]; then
  # If BASE_URL is set, replace the value in config.json
  if [ ! -z "$BASE_URL" ]; then
    sed -i "s|http://localhost:8080|$BASE_URL|g" /usr/share/nginx/html/assets/config.json
  fi

  # If WS_URL is set, replace the value in config.json
  if [ ! -z "$WS_URL" ]; then
    sed -i "s|ws://localhost:8080/ws/workspace/session|$WS_URL|g" /usr/share/nginx/html/assets/config.json
  fi

  echo "Configuration updated with environment variables."
  cat /usr/share/nginx/html/assets/config.json
fi

# Execute the passed command (nginx)
exec "$@"
