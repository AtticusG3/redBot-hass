# Changelog

## 1.2.0

- Install **socat** in the add-on image.
- Add optional **RPC bridge** (`rpc_bridge_enabled`, `rpc_bridge_port`, `rpc_target_port`) so Home Assistant Core (e.g. Red Discord RPC integration) can reach Red when `127.0.0.1` is wrong inside Core's container.
- Document LAN IP vs loopback and typical HA OS host **172.30.32.1** for integrations.

## 1.1.0

- Enable host network for local RPC access from the Home Assistant machine.
- Mount Home Assistant Share at `/share` (read-write) for custom cog paths.
- Mount add-on config at `/addon_config` (read-write) for custom cog paths without replacing `/config` in the image.

## 1.0.0

- Initial release: Red-DiscordBot via `phasecorex/red-discordbot`, options mapped from Supervisor UI, persistent `/data`.
