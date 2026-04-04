# Red Discord Bot add-on

This add-on runs [Red-DiscordBot](https://github.com/Cog-Creators/Red-DiscordBot) inside Home Assistant using the [phasecorex/red-discordbot](https://hub.docker.com/r/phasecorex/red-discordbot) image (default tag: `latest`, which includes Java for the **Audio** cog).

## Before you start

1. Create a Discord application and bot, and copy the bot **token** (see [Discord developer docs](https://discord.com/developers/docs/intro)).
2. Install this add-on from the store and **Start** it after setting at least **token** and **prefix** on first run.

## RPC (dashboards, scripts, and "Red Discord RPC" integration)

Red's RPC WebSocket listens on **`127.0.0.1` only** (you cannot change the bind address in Red for security reasons). That has two consequences:

1. **Do not use your LAN IP** (for example `192.168.1.x`) in any RPC client. Nothing is listening on that address, so the connection will fail. Your integration error that mentions the LAN IP is expected until you fix the host below.

2. **Home Assistant Core usually runs in its own container** (for example on Home Assistant OS). Inside that container, **`127.0.0.1` is Core itself**, not the host where this add-on runs. So **`127.0.0.1` often does not work** for the **Red Discord RPC** custom integration on HA OS even though the add-on uses host network.

This add-on sets **`host_network: true`** so Red attaches to the **supervisor host** network. You still need a path from **Core** to **host loopback RPC**.

### Option A: Try `127.0.0.1` (limited setups)

If your Home Assistant Core truly runs on the same network namespace as the host (uncommon), set the integration **RPC host** to **`127.0.0.1`** and the **RPC port** to Red's port (default **6133**). Some Docker Desktop setups work with **`host.docker.internal`** instead; follow your integration's documentation.

### Option B: RPC bridge (recommended on Home Assistant OS)

1. In Red, enable RPC (for example add **`--rpc`** to **extra_args** in this add-on if you have not already enabled RPC in the instance config).
2. In this add-on's options, enable **`rpc_bridge_enabled`**. Defaults: listen on host **`6134`**, forward to **`127.0.0.1:6133`** (Red's default RPC port). Change **rpc_target_port** if you set a custom RPC port in Red.
3. In the **Red Discord RPC** integration, set the host to the address Home Assistant Core uses to reach the **supervisor host**. On many HA OS installs this is **`172.30.32.1`**. Set the **port** to **`rpc_bridge_port`** (default **6134**), not 6133, because Core is connecting to the bridge, not to Red directly.

If **`172.30.32.1` does not work**, check your environment (VLANs, different Supervisor versions). The community often documents the current "host from Core" address for add-ons; your integration may also list alternatives.

**Security:** The bridge listens on **all interfaces** on the chosen host port while enabled. Anyone who can reach that port on your LAN could try to talk to Red RPC. Use a **strong RPC password** in Red, keep the integration updated, and disable the bridge when you do not need it.

### Enable RPC in Red

See [Red-DiscordBot documentation](https://docs.discord.red/) for RPC (`--rpc`, `--rpc-port`, etc.). You can pass flags via this add-on's **extra_args** option if needed.

**Security:** Host networking gives the add-on the same network view as the host. Only enable tools you trust, keep Red and your RPC password updated, and do not expose RPC to the internet.

## Installing cogs

### From Discord (typical)

Use Red as usual in your server, for example:

- `[p]repo add <repo_url>` then `[p]cog install <repo> <cog>`
- `[p]pipinstall <package>` when a cog needs extra Python packages (they install into the add-on data venv under `/data`)

You need a working internet connection from Home Assistant for downloads from GitHub and PyPI.

### Custom or local cogs (folders on disk)

This add-on mounts:

| Mount inside the container | What it is on Home Assistant |
|----------------------------|------------------------------|
| `/share` | Your **config/share** folder (same as **Settings > System > Storage** and Samba "share") |
| `/addon_config` | **Add-on configs** area for this repository (path shown in Supervisor; often used with Studio / File editor / SFTP) |

Put a cog repo or folder on the host, then in Discord tell Red to use that path, for example:

- `[p]addpath /share/redbot_cogs`
- or `[p]addpath /addon_config/my_cogs`

Restart or reload cogs as needed (`[p]reload` / `[p]cog reload` per Red docs).

If a cog needs **system packages** (apt libraries) that are not in the default image, use an image tag like **`extra`** / **`extra-audio`** (see [upstream image tags](https://github.com/PhasecoreX/docker-red-discordbot/blob/master/README.md)) or extend the image in a fork.

**Note:** The default **`addon_config`** Supervisor mount is mapped to **`/addon_config`** (not `/config`) so it does not replace the paths inside the PhasecoreX image that Red expects.

## Configuration

| Option | Maps to | Description |
|--------|---------|-------------|
| token | `TOKEN` | Discord bot token. Optional after Red has saved it to disk; you can clear it from the UI later for slightly faster startup (see upstream image docs). |
| prefix | `PREFIX` | Command prefix (e.g. `.`). |
| prefix2 - prefix5 | `PREFIX2` - `PREFIX5` | Extra prefixes (optional). |
| timezone | `TZ` | Timezone (e.g. `America/Detroit`). Default `UTC`. |
| puid / pgid | `PUID` / `PGID` | User/group IDs for files under `/data`. Default `1000`. |
| owner | `OWNER` | Discord user ID for bot owner (optional; can be set once then removed from options). |
| extra_args | `EXTRA_ARGS` | Extra arguments passed to Red on startup (e.g. `--debug`). See [Red docs](https://docs.discord.red/). |
| redbot_version | `REDBOT_VERSION` | Pip-style version pin (e.g. `==3.5.0`). Leave empty for latest on each restart. |
| niceness | `NICENESS` | Process nice value (-20 to 19). Values below the default may require extra privileges on the host; see upstream README. |
| rpc_bridge_enabled | (entrypoint) | If true, runs **socat** on the host: accepts TCP on **rpc_bridge_port** and forwards to **127.0.0.1:rpc_target_port** so HA Core can reach Red RPC. See RPC section. |
| rpc_bridge_port | (entrypoint) | Host port for the bridge (default **6134**). Use this port in the **Red Discord RPC** integration when the bridge is enabled. |
| rpc_target_port | (entrypoint) | Red RPC port on loopback (default **6133**). Match Red's `--rpc-port` if you changed it. |

## Data and backups

All bot data lives in the add-on **data** directory (`/data` in the container). Include this add-on in your Home Assistant **backups** so instances, cogs, and the venv are preserved.

## Security

- Treat the **token** like a password. Do not paste it into logs or community posts.
- **extra_args** such as `--debug` can increase log verbosity; avoid sharing logs that might contain sensitive data.
- **Host network** is required for local RPC; treat RPC credentials like admin access (see RPC section above).

## Advanced: image tag (build-time)

The default upstream image tag is `latest`. To use another tag (e.g. `core`, `extra-audio`, `extra-pylav`), rebuild the add-on locally with a Docker build argument `PCX_TAG` only if your workflow supports it, or fork this repository and change the default `ARG PCX_TAG` in `Dockerfile`. See the [upstream README](https://github.com/PhasecoreX/docker-red-discordbot/blob/master/README.md) for tag meanings.

## Audio cog

`audio: true` is set so Supervisor can map audio devices where supported. If audio stutters, the upstream image suggests host networking (already enabled here) or adjusting niceness; see their documentation.

## Support

- Packaging issues: open an issue on the Git repository that hosts this add-on.
- Red / image behavior: [PhasecoreX/docker-red-discordbot](https://github.com/PhasecoreX/docker-red-discordbot) and [Red-DiscordBot documentation](https://docs.discord.red/).
