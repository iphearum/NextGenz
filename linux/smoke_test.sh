#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEB_FILE="${ROOT_DIR}/dist/nextgenz_1.0.0_amd64.deb"

if [[ ! -f "${DEB_FILE}" ]]; then
  echo "Missing ${DEB_FILE}"
  exit 1
fi

apt-get remove -y nextgenz >/dev/null 2>&1 || true

dpkg -i "${DEB_FILE}"

/opt/NextGenz/bin/nextgenz-daemon --model-dir /opt/NextGenz/model --socket /tmp/nextgenz.sock >/tmp/nextgenz.log 2>&1 &
PID=$!
sleep 1

python3 -c 'import socket; s=socket.socket(socket.AF_UNIX, socket.SOCK_STREAM); s.connect("/tmp/nextgenz.sock"); s.sendall(b"PING\n"); print(s.recv(4096).decode("utf-8","replace").strip()); s.close()'

kill "${PID}" || true
rm -f /tmp/nextgenz.sock

apt-get remove -y nextgenz >/tmp/nextgenz-remove.log 2>&1 || true

if [[ -d /opt/NextGenz ]]; then
  echo "opt_exists_after_remove=yes"
  exit 2
fi

echo "opt_exists_after_remove=no"
echo "SMOKE_TEST_PASS"
