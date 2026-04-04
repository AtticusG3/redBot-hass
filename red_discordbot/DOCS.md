# Red Discord Bot add-on

This add-on runs [Red-DiscordBot](https://github.com/Cog-Creators/Red-DiscordBot) inside Home Assistant using the [phasecorex/red-discordbot](https://hub.docker.com/r/phasecorex/red-discordbot) image (default tag: `latest`, which includes Java for the **Audio** cog).

## Before you start

1. Create a Discord application and bot, and copy the bot **token** (see [Discord developer docs](https://discord.com/developers/docs/intro)).
2. Install this add-on from the store and **Start** it after setting at least **token** and **prefix** on first run.

## RPC (dashboards, scripts, and "Red Discord RPC" integration)

**RPC is enabled by default:** **extra_args** defaults to **`--rpc`**. If your integration cannot connect, the usual cause is RPC not running because **`--rpc` was removed** from **extra_args** (or an older add-on install never picked up the default). Add **`--rpc`** back, or combine flags with spaces, for example **`--rpc --debug`**.

Red's RPC WebSocket listens on **`127.0.0.1` only** (bind address is not configurable). Do not point clients at your **LAN IP** (`192.168.x.x`) unless you use a documented proxy; nothing listens there for RPC.

**Home Assistant Core** often runs in **another container** (for example on Home Assistant OS). There, **`127.0.0.1` is Core itself**, not the host where this add-on runs, so some setups need the **RPC bridge** below.

This add-on uses **`host_network: true`** so Red uses the **supervisor host** network.

### Option A: `127.0.0.1` or `host.docker.internal`

If Core can reach the host loopback (depends on your install), set the integration **host** to **`127.0.0.1`** and **port** to Red's RPC port (default **6133**), or follow your integration's note about **`host.docker.internal`**.

### Option B: RPC bridge (Home Assistant OS and similar)

1. Keep **`--rpc`** in **extra_args** (default).
2. Enable **`rpc_bridge_enabled`**. Defaults: host **`6134`** forward to **`127.0.0.1:6133`**. Adjust **rpc_target_port** if you changed Red's RPC port.
3. In the integration, use host **`172.30.32.1`** (common on HA OS) and port **`6134`** (bridge port), not 6133, when the bridge is on.

**Security:** The bridge listens on all interfaces on that port. Use a **strong RPC password** in Red. Disable the bridge when you do not need it.

More flags: see [Red-DiscordBot documentation](https://docs.discord.red/) (`--rpc-port`, etc.).

**Security:** Host networking gives the add-on the host's network view. Only enable tools you trust, keep Red and your RPC password updated, and do not expose RPC to the internet.

## Audio cog

The **`latest`** image includes **Java** so the **Audio** cog can run, but Red does **not** load Audio automatically. After the bot is online, run **`[p]load audio`** once (prefix may differ). Red will remember loaded cogs for future restarts. If Audio fails, confirm you use an **audio**-capable image tag and that **audio** is enabled for this add-on in Supervisor (PulseAudio mapping). If playback stutters, see the [upstream image README](https://github.com/PhasecoreX/docker-red-discordbot/blob/master/README.md) for niceness and networking tips.

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
| extra_args | `EXTRA_ARGS` | Defaults to **`--rpc`** so RPC integrations can connect. Add more flags separated by spaces (e.g. **`--rpc --debug`**). Clear only if you intentionally disable RPC startup flags. See [Red docs](https://docs.discord.red/). |
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

## Support

- Packaging issues: open an issue on the Git repository that hosts this add-on.
- Red / image behavior: [PhasecoreX/docker-red-discordbot](https://github.com/PhasecoreX/docker-red-discordbot) and [Red-DiscordBot documentation](https://docs.discord.red/).
