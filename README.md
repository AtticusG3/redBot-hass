# Red Bot Home Assistant Add-ons

This repository provides a [Home Assistant](https://www.home-assistant.io/) add-on that runs [Red-DiscordBot](https://github.com/Cog-Creators/Red-DiscordBot) using the [phasecorex/red-discordbot](https://hub.docker.com/r/phasecorex/red-discordbot) container image.

## Add-on: Red Discord Bot

Wraps `phasecorex/red-discordbot` so you can configure the bot from the Supervisor UI. Bot data persists in the add-on's `/data` volume.

## Installation

1. Open **Home Assistant**.
2. Go to **Settings** > **Add-ons** > **Add-on Store**.
3. Open the **three-dots menu** (top right) > **Repositories**.
4. Add this repository URL:

   `https://github.com/AtticusG3/redBot-hass`

5. Click **Add** and close the repositories dialog.
6. Refresh the store page, find **Red Discord Bot**, and install it.
7. Configure your Discord bot **token** and **prefix** (see the add-on **Documentation** tab), then **Start** the add-on.

### One-click repository link (optional)

After you know your public Git URL, you can generate an "Add repository" button at [my.home-assistant.io/redirect/supervisor_add_addon_repository/](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/).

## Requirements

- Home Assistant **OS** or **Supervised** installation (Supervisor required for the Add-on Store).

## Documentation

See [red_discordbot/DOCS.md](red_discordbot/DOCS.md) for configuration, backups, and advanced options.

## License

The add-on packaging in this repository is provided as-is. Red-DiscordBot and the PhasecoreX Docker image have their own licenses; see their upstream projects.
