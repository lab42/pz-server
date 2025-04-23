# Project Zomboid Dedicated Server - Docker

A Docker container for running a Project Zomboid dedicated server with SteamCMD and mod support.

## Features

- Easy configuration through environment variables
- Support for Workshop mods
- Persistent game data with Docker volumes
- Automatic server setup and configuration
- Self-registration for players or admin-only registration
- Based on Debian Bullseye for stability

## Quick Start

```bash
docker run -d \
  --name pzserver \
  -p 16261:16261/udp \
  -p 16261:16261/tcp \
  -p 16262:16262/udp \
  -p 16262:16262/tcp \
  -v pz-data:/opt/pzserver/Zomboid \
  -e PZSERVER_NAME="My PZ Server" \
  -e PZSERVER_PASSWORD="serverpassword" \
  -e PZSERVER_ADMIN_PASSWORD="adminpassword" \
  ghcr.io/username/pzserver:latest
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PZSERVER_PORT` | The main server port | `16261` |
| `PZSERVER_NAME` | Name shown in the server browser | `Docker PZ Server` |
| `PZSERVER_PASSWORD` | Password to join the server (empty for no password) | `""` |
| `PZSERVER_ADMIN_PASSWORD` | Password for admin commands | `changeme` |
| `PZSERVER_MAX_PLAYERS` | Maximum number of players allowed | `16` |
| `PZSERVER_MOD_NAMES` | Comma-separated list of Workshop mod IDs | `""` |
| `PZSERVER_MAP` | The map to use | `Muldraugh, KY` |
| `PZSERVER_MEMORY` | Memory allocation for the Java server | `2048m` |
| `PZSERVER_OPEN_USER_REGISTRATION` | Allow players to create their own accounts | `true` |

### Internal Environment Variables

These variables are used internally and typically don't need to be modified:

| Variable | Description | Default |
|----------|-------------|---------|
| `STEAMAPPID` | SteamCMD app ID for Project Zomboid | `380870` |
| `PZSERVER_PATH` | Installation path for PZ server | `/opt/pzserver` |
| `STEAMCMD_PATH` | Installation path for SteamCMD | `/opt/steamcmd` |

## Volumes

| Volume Path | Description |
|-------------|-------------|
| `/opt/pzserver/Zomboid` | Contains all server data, world saves, configs, and logs |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| `16261` | UDP/TCP | Main server connection port |
| `16262` | UDP/TCP | Secondary server port |

## User Registration

### Self-Registration (Default)
By default, players can create their own accounts when joining the server. To disable this feature:

```bash
-e PZSERVER_OPEN_USER_REGISTRATION=false
```

### Admin-Only Registration
If self-registration is disabled, administrators must create accounts for players using console commands:

```
/adduser username password
```

## Installing Mods

To install Steam Workshop mods, set the `PZSERVER_MOD_NAMES` environment variable with a comma-separated list of Workshop item IDs.

Example:
```bash
-e PZSERVER_MOD_NAMES="2200148440,2392709985"
```

You can find the Workshop ID in the URL of the mod on the Steam Workshop page:
`https://steamcommunity.com/sharedfiles/filedetails/?id=2200148440` → ID is `2200148440`

## Administration

### Accessing the Server Console

To access the server console:

```bash
docker attach pzserver
```

To detach without stopping the server, press `Ctrl+P` followed by `Ctrl+Q`.

### Server Commands

Once attached to the console, you can run admin commands like:

```
/adduser username password
/adduseradmin username
/setaccesslevel username admin
```

## Backup and Restore

### Backup

```bash
docker stop pzserver
docker run --rm -v pz-data:/data -v $(pwd):/backup alpine tar czf /backup/pz-backup.tar.gz -C /data .
docker start pzserver
```

### Restore

```bash
docker stop pzserver
docker run --rm -v pz-data:/data -v $(pwd):/backup alpine sh -c "rm -rf /data/* && tar xzf /backup/pz-backup.tar.gz -C /data"
docker start pzserver
```

## Common Issues

### Server Not Appearing in Browser

- Check that ports 16261 and 16262 are properly forwarded on your router/firewall
- Verify the server is running: `docker logs pzserver`
- Ensure the server is properly configured with visible settings

### Memory Issues

If your server is crashing due to memory constraints, increase the allocated memory:

```bash
-e PZSERVER_MEMORY=4096m
```

### Mod Loading Problems

Some mods require specific load orders or dependencies. Check the mod's Workshop page for requirements.

### User Registration Issues

If players are unable to register themselves:
- Verify `PZSERVER_OPEN_USER_REGISTRATION` is set to `true`
- Check server logs for any authentication errors
- Ensure the server is properly configured with correct access settings

## Building from Source

```bash
git clone https://github.com/username/pzserver-docker.git
cd pzserver-docker
docker build -t pzserver .
```

## License

This Docker configuration is provided under the MIT License. Project Zomboid itself is a proprietary game developed by The Indie Stone.

## Acknowledgements

- Project Zomboid is developed by [The Indie Stone](https://projectzomboid.com)
- SteamCMD is provided by [Valve Corporation](https://developer.valvesoftware.com/wiki/SteamCMD)
- This container uses [confd](https://github.com/kelseyhightower/confd) for configuration management
