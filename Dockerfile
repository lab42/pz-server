FROM debian:bullseye-slim

# Set environment variables
ENV STEAMAPPID=380870
ENV PZSERVER_PATH=/opt/pzserver
ENV STEAMCMD_PATH=/opt/steamcmd
ENV HOME=/root
ENV DEBIAN_FRONTEND=noninteractive

# Server and game settings with defaults
ENV PZSERVER_PORT=16261
ENV PZSERVER_NAME="Docker PZ Server"
ENV PZSERVER_PASSWORD=""
ENV PZSERVER_ADMIN_PASSWORD="changeme"
ENV PZSERVER_MAX_PLAYERS=16
ENV PZSERVER_MOD_NAMES=""
ENV PZSERVER_MAP="Muldraugh, KY"
ENV PZSERVER_MEMORY=2048m

# Install dependencies
RUN apt-get update && apt-get install -y \
    lib32gcc-s1 \
    lib32stdc++6 \
    wget \
    ca-certificates \
    locales \
    xvfb \
    libsdl2-2.0-0 \
    libsdl2-mixer-2.0-0 \
    libsdl2-image-2.0-0 \
    openjdk-17-jre-headless \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Create directories
RUN mkdir -p ${STEAMCMD_PATH} ${PZSERVER_PATH} /etc/confd/conf.d /etc/confd/templates /scripts

# Install SteamCMD
RUN wget -q -O /tmp/steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -xzf /tmp/steamcmd_linux.tar.gz -C ${STEAMCMD_PATH} \
    && rm /tmp/steamcmd_linux.tar.gz \
    && ${STEAMCMD_PATH}/steamcmd.sh +quit \
    && ln -s ${STEAMCMD_PATH}/linux32/steamclient.so ${STEAMCMD_PATH}/steamclient.so

# Install confd
RUN curl -L -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 \
    && chmod +x /usr/local/bin/confd

# Copy scripts and templates
COPY scripts/ /scripts/
COPY confd/ /etc/confd/

# Make scripts executable
RUN chmod +x /scripts/*.sh

# Expose required ports
EXPOSE 16261/udp 16261/tcp
EXPOSE 16262/udp 16262/tcp

# Set volumes for saves and logs
VOLUME ["${PZSERVER_PATH}/Zomboid"]

# Set working directory
WORKDIR ${PZSERVER_PATH}

# Start the server
CMD ["/scripts/entrypoint.sh"]
