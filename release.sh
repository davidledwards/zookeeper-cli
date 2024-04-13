#!/bin/bash

if [[ -z $(which gh) ]]; then
    echo "GitHub CLI not found (see https://cli.github.com/)"
    exit 1
fi

# Derive version number from build script.
__VERSION=$(grep "version :=" build.sbt | sed -r "s/^.*version := \"(.*)\",.*$/\1/")
echo "building ${__VERSION}"

sbt clean compile test packArchive
if [ $? -ne 0 ]; then
    echo "build failed"
    exit 1
fi

# Create checksums for published artifacts.
__BIN_DIR=$(pwd)/target
__BIN_NAME="zookeeper-cli-${__VERSION}"
__TAR="${__BIN_NAME}.tar.gz"
__ZIP="${__BIN_NAME}.zip"

(cd "$__BIN_DIR" && \
    shasum -a 256 "${__TAR}" > "${__TAR}.sha256" && \
    shasum -a 256 "${__ZIP}" > "${__ZIP}.sha256")

gh release create --title "${__VERSION}" --generate-notes "v${__VERSION}" \
    "${__BIN_DIR}/${__TAR}" \
    "${__BIN_DIR}/${__TAR}.sha256" \
    "${__BIN_DIR}/${__ZIP}" \
    "${__BIN_DIR}/${__ZIP}.sha256"

echo "released ${__VERSION}"
