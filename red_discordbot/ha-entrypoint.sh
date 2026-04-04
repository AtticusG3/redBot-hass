#!/bin/bash
set -euo pipefail

OPTIONS=/data/options.json

export_if_set() {
  local json_key=$1
  local env_name=$2
  local val
  val=$(jq -r ".${json_key} // empty" "$OPTIONS" 2>/dev/null || true)
  if [[ -n "$val" ]]; then
    printf -v "${env_name}" '%s' "$val"
    export "${env_name}"
  fi
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
