#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
scratch_dir=$(mktemp -d "${TMPDIR:-/tmp}/magi-ios-ui.XXXXXX")
fixture_pid=''
cleanup() {
  if [[ -n "$fixture_pid" ]]; then kill "$fixture_pid" 2>/dev/null || true; wait "$fixture_pid" 2>/dev/null || true; fi
}
trap cleanup EXIT
python3 scripts/ui-fixture.py > "$scratch_dir/fixture.log" 2>&1 &
fixture_pid=$!
python3 - "$fixture_pid" <<'PY'
import os, sys, time, urllib.request
for _ in range(50):
    time.sleep(.1)
    os.kill(int(sys.argv[1]), 0)
    try:
        urllib.request.urlopen('http://127.0.0.1:18992/test/state', timeout=1).close()
        break
    except OSError:
        continue
else:
    raise SystemExit('UI fixture did not start')
PY
if [[ -z "${SIMULATOR_ID:-}" ]]; then
  SIMULATOR_ID=$(xcrun simctl list devices available --json | python3 -c 'import json,sys; print(next(d["udid"] for ds in json.load(sys.stdin)["devices"].values() for d in ds if d["name"].startswith("iPhone")))')
fi
xcodebuild -project MagiIOS.xcodeproj -scheme MagiIOS \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  -derivedDataPath "$scratch_dir/DerivedData" -resultBundlePath "$scratch_dir/Results.xcresult" \
  -parallel-testing-enabled NO CODE_SIGN_IDENTITY=- test "$@"
echo "UI results: $scratch_dir/Results.xcresult"
