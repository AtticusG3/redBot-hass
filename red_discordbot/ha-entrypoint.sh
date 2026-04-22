#!/bin/bash
set -euo pipefail

OPTIONS=/data/options.json
BUNDLED_COG_PATH=/opt/redbot-media-player/bundled_cogs/ha_red_rpc

export_if_set() {
  local json_key=$1
  local env_name=$2
  local val
  val=$(jq -r ".${json_key} // empty" "$OPTIONS" 2>/dev/null || true)
  if [[ -n "$val" ]]; then
    export "${env_name}=${val}"
  fi
}

json_or_default() {
  local key=$1
  local default_value=$2
  local value
  value=$(jq -r ".${key} // empty" "$OPTIONS" 2>/dev/null || true)
  if [[ -z "$value" || "$value" == "null" ]]; then
    echo "$default_value"
    return
  fi
  echo "$value"
}

dir_has_entries() {
  local dir_path=$1
  local entry
  for entry in "$dir_path"/* "$dir_path"/.[!.]* "$dir_path"/..?*; do
    if [[ -e "$entry" ]]; then
      return 0
    fi
  done
  return 1
}

seed_bundled_cog() {
  local target_path=$1
  local seed_marker="$target_path/.ha_red_rpc_seeded_snapshot"
  if [[ ! -d "$BUNDLED_COG_PATH" ]]; then
    echo "[ha-entrypoint] bundled cog path missing: $BUNDLED_COG_PATH" >&2
    return
  fi
  mkdir -p "$target_path"
  if [[ ! -f "$target_path/ha_red_rpc.py" ]]; then
    echo "[ha-entrypoint] Seeding bundled ha_red_rpc snapshot to $target_path" >&2
    cp -a "$BUNDLED_COG_PATH/." "$target_path/"
    : >"$seed_marker"
  fi
}

sync_cog_repo() {
  local target_path=$1
  local repo_url=$2
  local repo_ref=$3
  local seed_marker="$target_path/.ha_red_rpc_seeded_snapshot"
  if [[ -z "$repo_url" ]]; then
    echo "[ha-entrypoint] cog_auto_sync enabled but cog_repo_url is empty; skipping" >&2
    return
  fi
  mkdir -p "$target_path"
  if [[ -d "$target_path/.git" ]]; then
    echo "[ha-entrypoint] Updating ha_red_rpc from $repo_url@$repo_ref" >&2
    if git -C "$target_path" remote get-url origin >/dev/null 2>&1; then
      git -C "$target_path" remote set-url origin "$repo_url" || return
    else
      git -C "$target_path" remote add origin "$repo_url" || return
    fi
    git -C "$target_path" fetch --depth=1 origin "$repo_ref" || return
    git -C "$target_path" checkout -q --force FETCH_HEAD || return
    return
  fi
  if dir_has_entries "$target_path" && [[ ! -f "$seed_marker" ]]; then
    echo "[ha-entrypoint] Existing non-git cog directory found at $target_path; leaving seeded files in place" >&2
    return
  fi
  echo "[ha-entrypoint] Syncing ha_red_rpc from $repo_url@$repo_ref into $target_path" >&2
  git -C "$target_path" init -q || return
  if git -C "$target_path" remote get-url origin >/dev/null 2>&1; then
    git -C "$target_path" remote set-url origin "$repo_url" || return
  else
    git -C "$target_path" remote add origin "$repo_url" || return
  fi
  git -C "$target_path" fetch --depth=1 origin "$repo_ref" || return
  git -C "$target_path" checkout -q --force FETCH_HEAD || return
  rm -f "$seed_marker"
}

attempt_auto_load() {
  local target_path=$1
  echo "[ha-entrypoint] cog_auto_load requested; attempting best-effort bootstrap commands" >&2
  if command -v redbot-cli >/dev/null 2>&1; then
    (
      sleep 20
      redbot-cli --command "addpath $(dirname "$target_path")" >/dev/null 2>&1 || true
      redbot-cli --command "load ha_red_rpc" >/dev/null 2>&1 || true
    ) &
    return
  fi
  echo "[ha-entrypoint] redbot-cli not available; run once in Discord: [p]addpath $(dirname "$target_path") && [p]load ha_red_rpc" >&2
}

if [[ -f "$OPTIONS" ]]; then
  export_if_set token TOKEN
  export_if_set prefix PREFIX
  export_if_set prefix2 PREFIX2
  export_if_set prefix3 PREFIX3
  export_if_set prefix4 PREFIX4
  export_if_set prefix5 PREFIX5
  export_if_set timezone TZ
  export_if_set puid PUID
  export_if_set pgid PGID
  export_if_set owner OWNER
  export_if_set extra_args EXTRA_ARGS
  export_if_set redbot_version REDBOT_VERSION
  export_if_set niceness NICENESS

  cog_auto_sync=$(json_or_default "cog_auto_sync" "true")
  cog_auto_load=$(json_or_default "cog_auto_load" "true")
  cog_repo_url=$(json_or_default "cog_repo_url" "https://github.com/AtticusG3/redbot-media-player-cog.git")
  cog_ref=$(json_or_default "cog_ref" "main")
  cog_install_path=$(json_or_default "cog_install_path" "/share/redbot_cogs/ha_red_rpc")
  seed_bundled_cog "$cog_install_path"
  if [[ "$cog_auto_sync" == "true" ]]; then
    sync_cog_repo "$cog_install_path" "$cog_repo_url" "$cog_ref" || \
      echo "[ha-entrypoint] WARNING: cog sync failed, using local snapshot" >&2
  fi
  if [[ "$cog_auto_load" == "true" ]]; then
    attempt_auto_load "$cog_install_path"
  fi

  # Optional TCP bridge so Home Assistant Core (or other containers) can reach Red RPC.
  # Red binds RPC to 127.0.0.1 on the host only; LAN IP never works. On HA OS, Core's
  # 127.0.0.1 is not the host loopback, so enable this and point the integration at
  # 172.30.32.1:<rpc_bridge_port> (typical) or your documented host-gateway IP.
  bridge=$(jq -r '.rpc_bridge_enabled // false' "$OPTIONS" 2>/dev/null || echo false)
  if [[ "$bridge" == "true" ]]; then
    bp=$(jq -r '.rpc_bridge_port // 6134' "$OPTIONS")
    tp=$(jq -r '.rpc_target_port // 6133' "$OPTIONS")
    echo "[ha-entrypoint] Starting RPC bridge: listen *:${bp} -> 127.0.0.1:${tp}" >&2
    nohup socat "TCP-LISTEN:${bp},fork,reuseaddr" "TCP:127.0.0.1:${tp}" >/dev/null 2>&1 &
  fi
fi

exec /bin/user-entrypoint "$@"
