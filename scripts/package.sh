#!/bin/sh

GAME_VERSION="1_11_2929_2"
PKG_BASE_COMMIT="7cebdc80ca43aca55809475c58b19ce3215c1666"

ROOT_DIR="$(dirname "$0")/.."
ANCILLA="ancilla"

PKG_BUILD_DIR="${ROOT_DIR}/build"
PKG_DIFF_DIR="${PKG_BUILD_DIR}/diff"
PKG_BUNDLE_DIR="${PKG_BUILD_DIR}/GTS/${GAME_VERSION}_active"

PKG_DATA_EXTENSIONS='\.xml$|\.cfg$|\.ddx$|\.tactics$|\.vis$'
PKG_DATA_FILES=$(git diff --name-only HEAD ${PKG_BASE_COMMIT} | egrep ${PKG_DATA_EXTENSIONS})

PKG_FILE_NAME="maethrillian.pkg"
PKG_FILE_PATH="${PKG_BUNDLE_DIR}/${PKG_FILE_NAME}"
PKG_FILE_MANIFEST="${PKG_BUNDLE_DIR}/${GAME_VERSION}_file_manifest.xml"
PKG_ARCHIVE="maethrillian.zip"

[ -x "$(command -v ${ANCILLA})" ] \
    && { echo "[ OK   ] Check ancilla binary"; } \
    || { echo "[ ERR  ] Check ancilla binary"; exit 1; }

set -e

cd ${ROOT_DIR}

rm -rf ${PKG_BUILD_DIR}
mkdir -p ${PKG_DIFF_DIR} ${PKG_BUNDLE_DIR}
echo "[ OK   ] Clean build directory"

cp --parents ${PKG_DATA_FILES} ${PKG_DIFF_DIR}
echo "[ OK   ] Extract diff"

${ANCILLA} package -o ${PKG_FILE_PATH} ${PKG_DIFF_DIR}
echo "[ OK   ] Create package"

PKG_PUBLISHED_UTC=$(date +%s)
PKG_PUBLISHED_UTC_TEXT=$(date -u)
PKG_FILE_CHECKSUM=$(${ANCILLA} checksum ${PKG_FILE_PATH} | tr -d '\n')

cat >${PKG_FILE_MANIFEST} <<EOF
<manifest published_utc="${PKG_PUBLISHED_UTC}" published_utc_str="${PKG_PUBLISHED_UTC_TEXT}">
	<file action="replace" crc32="${PKG_FILE_CHECKSUM}" new="${PKG_FILE_NAME}" old="${PKG_FILE_NAME}" size="0" time="0" version="1" />
</manifest>
EOF
echo "[ OK   ] Create manifest"

rm -rf ${PKG_DIFF_DIR}
