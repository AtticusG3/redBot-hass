# Changelog

## 1.0.0

- Bundle `ha_red_rpc` with the add-on image and seed it to `/share/redbot_cogs/ha_red_rpc` for RedBot Media Player.
- Add startup cog sync options (`cog_auto_sync`, `cog_repo_url`, `cog_ref`, `cog_install_path`) with bundled-snapshot fallback when sync fails (offline, upstream unavailable, or invalid ref).
- Add best-effort cog auto-load option (`cog_auto_load`) so new installs can come up ready with minimal manual steps; fallback remains:
  - `[p]addpath /share/redbot_cogs`
  - `[p]load ha_red_rpc`
- Set default sync source to `https://github.com/AtticusG3/redbot-media-player-cog.git` at `main` (override with `cog_repo_url` / `cog_ref` if needed).

### Notes

- This repository now treats `1.0.0` as the first public release baseline for the RedBot Media Player channel.
- Earlier iterations were alpha/internal and are not carried as public semver history.
