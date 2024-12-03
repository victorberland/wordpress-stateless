#!/usr/bin/env bash
set -Eeuo pipefail

service redis-server restart
exec "$@"
