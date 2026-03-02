#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-1.0.0}"
ARCH="${2:-amd64}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
DIST_DIR="${ROOT_DIR}/dist"
PKG_WORK_BASE="$(mktemp -d /tmp/nextgenz-pkg-XXXXXX)"
PKG_DIR="${PKG_WORK_BASE}/pkgroot"
MODEL_SRC="${ROOT_DIR}/../payload/bin/model_dll"

if [[ ! -x "${BUILD_DIR}/nextgenz-daemon" ]]; then
  echo "Missing daemon binary. Run ./build.sh first."
  exit 1
fi

if [[ ! -f "${MODEL_SRC}/prefix.tsv" || ! -f "${MODEL_SRC}/next.tsv" ]]; then
  echo "Missing model files in ${MODEL_SRC}"
  exit 1
fi

mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${PKG_DIR}/opt/NextGenz/bin"
mkdir -p "${PKG_DIR}/opt/NextGenz/model"
mkdir -p "${PKG_DIR}/lib/systemd/system"

cp "${BUILD_DIR}/nextgenz-daemon" "${PKG_DIR}/opt/NextGenz/bin/nextgenz-daemon"
cp "${MODEL_SRC}/prefix.tsv" "${PKG_DIR}/opt/NextGenz/model/prefix.tsv"
cp "${MODEL_SRC}/next.tsv" "${PKG_DIR}/opt/NextGenz/model/next.tsv"
if [[ -f "${MODEL_SRC}/meta.txt" ]]; then
  cp "${MODEL_SRC}/meta.txt" "${PKG_DIR}/opt/NextGenz/model/meta.txt"
fi

cp "${ROOT_DIR}/debian/nextgenz.service" "${PKG_DIR}/lib/systemd/system/nextgenz.service"
sed "s/__VERSION__/${VERSION}/g" "${ROOT_DIR}/debian/control" > "${PKG_DIR}/DEBIAN/control"
cp "${ROOT_DIR}/debian/postinst" "${PKG_DIR}/DEBIAN/postinst"
cp "${ROOT_DIR}/debian/prerm" "${PKG_DIR}/DEBIAN/prerm"
cp "${ROOT_DIR}/debian/postrm" "${PKG_DIR}/DEBIAN/postrm"

chmod 0755 "${PKG_DIR}/DEBIAN/postinst" "${PKG_DIR}/DEBIAN/prerm" "${PKG_DIR}/DEBIAN/postrm"
chmod 0755 "${PKG_DIR}/opt/NextGenz/bin/nextgenz-daemon"

mkdir -p "${DIST_DIR}"
DEB_FILE="${DIST_DIR}/nextgenz_${VERSION}_${ARCH}.deb"
dpkg-deb --build "${PKG_DIR}" "${DEB_FILE}"
rm -rf "${PKG_WORK_BASE}"

echo "Created: ${DEB_FILE}"
