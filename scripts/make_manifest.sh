#!/usr/bin/env bash
# Usage: ./scripts/make_manifest.sh > outputs/manifest.sha256

set -euo pipefail

echo "# SHA-256 manifest for caffeine_v1 (generated $(date -u +%Y-%m-%dT%H:%M:%SZ))"
find inputs outputs analysis provenance -type f ! -name "manifest.sha256" -print0 | sort -z | xargs -0 shasum -a 256

