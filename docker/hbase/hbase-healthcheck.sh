#!/usr/bin/env bash
set -euo pipefail

printf "%s\n" "status 'simple'" "exit" \
  | /opt/hbase/bin/hbase shell -n 2>/dev/null \
  | grep 'active master' >/dev/null
