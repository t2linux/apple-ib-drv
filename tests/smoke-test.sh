#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

kernel_build_dir=${KDIR:-/lib/modules/$(uname -r)/build}
checkpatch=${CHECKPATCH:-$kernel_build_dir/scripts/checkpatch.pl}
checkpatch_output=$(mktemp)

cleanup() {
  rm -f "$checkpatch_output"
}

trap cleanup EXIT

required_files=(
  "MAINTAINERS"
  "Documentation/ABI/testing/sysfs-driver-hid-apple-touchbar"
  "Documentation/hid/apple-touchbar.rst"
  "docs/upstream/COVER_LETTER_v1.txt"
  "docs/upstream/SUBMISSION_CHECKLIST.md"
)

printf '==> Cleaning previous build artifacts\n'
make clean >/dev/null 2>&1 || true

printf '==> Building modules with W=1\n'
make W=1

if [[ ! -x "$checkpatch" ]]; then
  printf 'checkpatch not found at %s\n' "$checkpatch" >&2
  exit 1
fi

printf '==> Running checkpatch --strict\n'
if ! "$checkpatch" --no-tree --strict \
  apple-ibridge.c \
  apple-touchbar.c \
  apple-ibridge.h | tee "$checkpatch_output"; then
  if grep -q '^total: 0 errors, 0 warnings, 1 checks' "$checkpatch_output" &&
     grep -q 'bConfigurationValue' "$checkpatch_output" &&
     grep -q 'bInterfaceNumber' "$checkpatch_output" &&
     ! grep -q '^ERROR:' "$checkpatch_output" &&
     ! grep -q '^WARNING:' "$checkpatch_output"; then
    printf '==> checkpatch only reported the two expected CamelCase USB field checks\n'
  else
    exit 1
  fi
fi

printf '==> Verifying required submission artifacts\n'
for path in "${required_files[@]}"; do
  [[ -f "$path" ]] || {
    printf 'Missing required file: %s\n' "$path" >&2
    exit 1
  }
done

printf 'Smoke test passed.\n'
