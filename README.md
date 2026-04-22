# Red Bot Home Assistant Add-ons

This repository provides a [Home Assistant](https://www.home-assistant.io/) add-on that runs [Red-DiscordBot](https://github.com/Cog-Creators/Red-DiscordBot) using the [phasecorex/red-discordbot](https://hub.docker.com/r/phasecorex/red-discordbot) container image.

## Add-on: Red Discord Bot

Wraps `phasecorex/red-discordbot` so you can configure the bot from the Supervisor UI. Bot data persists in the add-on's `/data` volume. **extra_args** defaults to **`--rpc`**. **Host network** is enabled for RPC; optional **RPC bridge** helps HA Core reach the bot on some installs. **Share** and **add-on config** are mounted for custom cog paths.

For **RedBot Media Player**, the add-on bundles `ha_red_rpc` and can auto-manage it at startup:

- `cog_auto_sync` (default `true`) syncs from `cog_repo_url` at `cog_ref`.
- If sync fails, the bundled snapshot is kept as a reliability fallback.
- `cog_auto_load` (default `true`) attempts one-time runtime loading; if unavailable in your Red image, run:
  - `[p]addpath /share/redbot_cogs`
  - `[p]load ha_red_rpc`

Load the **Audio** cog once with **`[p]load audio`** (see add-on documentation).

Related RedBot Media Player repositories:

- Cog source: [AtticusG3/redbot-media-player-cog](https://github.com/AtticusG3/redbot-media-player-cog)
- Home Assistant integration: [AtticusG3/redbot-media-player-homeassistant](https://github.com/AtticusG3/redbot-media-player-homeassistant)

## Installation

1. Open **Home Assistant**.
2. Go to **Settings** > **Add-ons** > **Add-on Store**.
3. Open the **three-dots menu** (top right) > **Repositories**.
4. Add this repository URL:

   `https://github.com/AtticusG3/redBot-hass`

5. Click **Add** and close the repositories dialog.
6. Refresh the store page, find **Red Discord Bot**, and install it.
7. Configure your Discord bot **token** and **prefix** (see the add-on **Documentation** tab), then **Start** the add-on.
8. For first-run Discord commands (Audio and `ha_red_rpc` fallback commands), follow `red_discordbot/DOCS.md`.

### One-click repository link (optional)

After you know your public Git URL, you can generate an "Add repository" button at [my.home-assistant.io/redirect/supervisor_add_addon_repository/](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/).

## Requirements

- Home Assistant **OS** or **Supervised** installation (Supervisor required for the Add-on Store).

## Documentation

See [red_discordbot/DOCS.md](red_discordbot/DOCS.md) for configuration, RPC details, bundled+auto-sync behavior, and fallback commands.  
See [red_discordbot/CHANGELOG.md](red_discordbot/CHANGELOG.md) for release history.

## License

The add-on packaging in this repository is provided as-is. Red-DiscordBot and the PhasecoreX Docker image have their own licenses; see their upstream projects.
