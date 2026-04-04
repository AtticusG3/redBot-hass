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
fi

exec /bin/user-entrypoint "$@"
