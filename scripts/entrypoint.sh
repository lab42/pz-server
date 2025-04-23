#!/bin/bash

# Process confd templates
echo "Processing configuration templates..."
confd -onetime -backend env

# Install/update server and mods
echo "Installing/updating Project Zomboid server..."
/scripts/update.sh

# Start the server
echo "Starting Project Zomboid server..."
cd ${PZSERVER_PATH}
exec ./start-server.sh \
  -servername servertest \
  -adminpassword "${PZSERVER_ADMIN_PASSWORD}" \
  -ip 0.0.0.0 \
  -port ${PZSERVER_PORT} \
  -xms ${PZSERVER_MEMORY} \
  -xmx ${PZSERVER_MEMORY}
