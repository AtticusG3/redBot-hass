# Changelog

## 1.1.0

- Enable host network for local RPC access from the Home Assistant machine.
- Mount Home Assistant Share at `/share` (read-write) for custom cog paths.
- Mount add-on config at `/addon_config` (read-write) for custom cog paths without replacing `/config` in the image.

## 1.0.0

- Initial release: Red-DiscordBot via `phasecorex/red-discordbot`, options mapped from Supervisor UI, persistent `/data`.
