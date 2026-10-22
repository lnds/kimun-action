#!/usr/bin/env bash
# Install the km binary of a kimun release for this runner, checked against
# the checksums the release publishes.
set -euo pipefail

case "$RUNNER_OS-$RUNNER_ARCH" in
  Linux-X64) target=x86_64-unknown-linux-gnu; ext=tar.gz ;;
  Linux-ARM64) target=aarch64-unknown-linux-gnu; ext=tar.gz ;;
  macOS-ARM64) target=aarch64-apple-darwin; ext=tar.gz ;;
  Windows-X64) target=x86_64-pc-windows-msvc; ext=zip ;;
  *)
    echo "::error::kimun publishes no binary for $RUNNER_OS $RUNNER_ARCH; install it with 'cargo install kimun' before this step"
    exit 1
    ;;
esac

asset="km-$target.$ext"
if [ "$KM_VERSION" = latest ]; then
  base=https://github.com/lnds/kimun/releases/latest/download
else
  base="https://github.com/lnds/kimun/releases/download/v${KM_VERSION#v}"
fi

dir="$RUNNER_TEMP/kimun"
mkdir -p "$dir/bin"
cd "$dir"
curl -fsSL --retry 3 -o "$asset" "$base/$asset"
curl -fsSL --retry 3 -o checksums-sha256.txt "$base/checksums-sha256.txt"

expected=$(grep " $asset\$" checksums-sha256.txt | cut -d' ' -f1)
if command -v sha256sum >/dev/null; then
  actual=$(sha256sum "$asset" | cut -d' ' -f1)
else
  actual=$(shasum -a 256 "$asset" | cut -d' ' -f1)
fi
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  echo "::error::checksum of $asset does not match the release"
  exit 1
fi

case "$ext" in
  zip) unzip -q -o "$asset" -d bin ;;
  *) tar xzf "$asset" -C bin ;;
esac
echo "$dir/bin" >> "$GITHUB_PATH"
"$dir/bin/km" --version
