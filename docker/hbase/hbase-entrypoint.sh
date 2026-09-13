#!/usr/bin/env bash
set -euo pipefail

stop_hbase() {
  /opt/hbase/bin/stop-hbase.sh
  exit 0
}

trap stop_hbase TERM INT

/opt/hbase/bin/start-hbase.sh

while pgrep -f 'org.apache.hadoop.hbase.master.HMaster' >/dev/null; do
  sleep 5 &
  wait $!
done

exit 1
