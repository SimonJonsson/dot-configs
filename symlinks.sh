#!/usr/bin/env bash
# Kept for muscle memory: link the configs, install nothing.
exec "$(dirname "$0")/install.sh" --links-only "$@"
