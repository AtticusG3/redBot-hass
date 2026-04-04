# Red Discord Bot add-on

This add-on runs [Red-DiscordBot](https://github.com/Cog-Creators/Red-DiscordBot) inside Home Assistant using the [phasecorex/red-discordbot](https://hub.docker.com/r/phasecorex/red-discordbot) image (default tag: `latest`, which includes Java for the **Audio** cog).

## Before you start

1. Create a Discord application and bot, and copy the bot **token** (see [Discord developer docs](https://discord.com/developers/docs/intro)).
2. Install this add-on from the store and **Start** it after setting at least **token** and **prefix** on first run.

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

## Data and backups

All bot data lives in the add-on **data** directory (`/data` in the container). Include this add-on in your Home Assistant **backups** so instances, cogs, and the venv are preserved.

## Security

- Treat the **token** like a password. Do not paste it into logs or community posts.
- **extra_args** such as `--debug` can increase log verbosity; avoid sharing logs that might contain sensitive data.

## Advanced: image tag (build-time)

The default upstream image tag is `latest`. To use another tag (e.g. `core`, `extra-audio`, `extra-pylav`), rebuild the add-on locally with a Docker build argument `PCX_TAG` only if your workflow supports it, or fork this repository and change the default `ARG PCX_TAG` in `Dockerfile`. See the [upstream README](https://github.com/PhasecoreX/docker-red-discordbot/blob/master/README.md) for tag meanings.

## Advanced: host network and RPC

Some integrations need Red's RPC on localhost. That may require **host network** mode on Docker; Home Assistant exposes this as an advanced add-on option only if enabled in `config.yaml` (`host_network: true`). This repository leaves **host network** off by default for security. If you need it, maintain a fork or local override and consult the [PhasecoreX README](https://github.com/PhasecoreX/docker-red-discordbot/blob/master/README.md).

## Audio cog

`audio: true` is set so Supervisor can map audio devices where supported. If audio stutters, the upstream image suggests trying host networking or adjusting niceness; see their documentation.

## Support

- Packaging issues: open an issue on the Git repository that hosts this add-on.
- Red / image behavior: [PhasecoreX/docker-red-discordbot](https://github.com/PhasecoreX/docker-red-discordbot) and [Red-DiscordBot documentation](https://docs.discord.red/).
