#!/usr/bin/env sh
SRC_DIR="${1}"
BIN="${2}"
UUID="${3}"

export CGO_ENABLED="0"
export GOOS="linux"
export GOARCH="amd64"

cd "${SRC_DIR}" || exit 1
go build -o "${BIN}" .

echo "{\"uuid\":\"${UUID}\"}"
