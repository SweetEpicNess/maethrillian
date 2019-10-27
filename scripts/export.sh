#!/bin/sh

ROOT_DIR="$(dirname "$0")/.."
DUMP_DIR=$1
OUT_DIR=/tmp/maethrillian

ANCILLA="~/Repositories/ancilla/target/release/ancilla"

rm -rf ${OUT_DIR}

for SRCDIR in ${DUMP_DIR}/data/db/lists ${DUMP_DIR}/data/db/tactics ${DUMP_DIR}/data/db/text/english
do
    for FILE in $(find ${SRCDIR} -type f | egrep '\.(xml|tactics|vis)\.xmb')
    do
        REL_FILE=$(realpath --relative-to=${DUMP_DIR} ${FILE})
        REL_FILE_PREFIX=${REL_FILE%.xmb}
        DEST_PATH=${OUT_DIR}/${REL_FILE_PREFIX}
        DEST_DIR=$(dirname ${DEST_PATH})
        
        mkdir -p ${DEST_DIR}
        ${ANCILLA} xmb2l ${FILE} -o ${DEST_PATH}
    done
done
