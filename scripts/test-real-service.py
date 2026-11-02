#!/usr/bin/env python3
"""Run the native Swift client against an isolated real Magi service (no model key)."""
import argparse
import json
import os
from pathlib import Path
from queue import Queue
import subprocess
import tempfile
import threading
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--magi', type=Path, required=True)
parser.add_argument('--executable', type=Path, required=True)
args = parser.parse_args()
os.umask(0o077)
root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='magi-ios-live-', dir='/tmp') as temporary:
    temporary = str(Path(temporary).resolve())
    config = Path(temporary) / 'server.json'
    executable = str(args.executable.resolve())
    subprocess.run([executable, 'init', '--config', str(config), '--data-dir', str(Path(temporary) / 'data'),
                    '--port', '0', '--development-root', str(args.magi.resolve())], check=True, capture_output=True)
    with (Path(temporary) / 'service.log').open('w') as log:
        process = subprocess.Popen([executable, 'run', '--config', str(config)], stdin=subprocess.DEVNULL,
                                   stdout=subprocess.PIPE, stderr=log, text=True)
        try:
            output = Queue()
            threading.Thread(target=lambda: output.put(process.stdout.readline()), daemon=True).start()
            base = json.loads(output.get(timeout=30))['baseUrl']

            def operator(command):
                result = subprocess.run([executable, command, '--config', str(config), '--json'], check=True, capture_output=True, text=True)
                return json.loads(result.stdout)

            deadline = time.monotonic() + 120
            while not operator('status').get('service_ready'):
                if process.poll() is not None or time.monotonic() > deadline:
                    log.flush()
                    print((Path(temporary) / 'service.log').read_text()[-12000:])
                    print(json.dumps(operator('status'), indent=2))
                    raise RuntimeError('Temporary service did not become ready')
                time.sleep(.25)
            env = dict(os.environ, MAGI_TEST_SERVICE=base, MAGI_TEST_PAIRING=operator('pair')['pairing_token'])
            subprocess.run(['swift', 'test', '--package-path', 'Packages/MagiCore', '--filter', 'realServiceClient'],
                           cwd=root, env=env, check=True, timeout=180)
        finally:
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=20)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=5)
