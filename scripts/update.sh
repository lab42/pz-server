#!/bin/bash
# /scripts/update_server.sh

# Update/install the PZ server
${STEAMCMD_PATH}/steamcmd.sh +force_install_dir ${PZSERVER_PATH} +login anonymous +app_update ${STEAMAPPID} validate +quit

# Check if mods need to be installed
if [ ! -z "${PZSERVER_MOD_NAMES}" ]; then
  echo "Installing/updating mods: ${PZSERVER_MOD_NAMES}"
  WORKSHOP_PATH="${PZSERVER_PATH}/steamapps/workshop"
  mkdir -p "${WORKSHOP_PATH}"
  
  # Convert comma-separated list to array
  IFS=',' read -ra MOD_IDS <<< "${PZSERVER_MOD_NAMES}"
  
  for MOD_ID in "${MOD_IDS[@]}"; do
    MOD_ID=$(echo ${MOD_ID} | xargs)
    if [[ ! -z "${MOD_ID}" ]]; then
      echo "Installing mod ID: ${MOD_ID}"
      ${STEAMCMD_PATH}/steamcmd.sh +login anonymous +workshop_download_item 108600 ${MOD_ID} +quit
    fi
  done
fi

echo "Server and mods installation complete."
