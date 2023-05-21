#!/usr/bin/env bash

set -eux

# https://github.com/stern/stern/blob/v1.25.0/.goreleaser.yaml#L7-L9
LDFLAGS="-X github.com/stern/stern/cmd.version=$PKG_VERSION-$PKG_BUILDNUM"

go build -v -ldflags="$LDFLAGS" -o $PREFIX/bin/stern .

# Cross-compilation: check correct architecture was built
declare -A expected
expected["darwin amd64"]='Mach-O.+x86_64'
expected["darwin arm64"]='Mach-O.+arm64'
expected["linux amd64"]='ELF.+x86-64'
expected["linux arm64"]='ELF.+aarch64'
if [ -n "$GOARCH" ]; then
  file $PREFIX/bin/stern | grep -E "${expected["$GOOS $GOARCH"]}"
fi

go-licenses save . --save_path=./license-files
test -d license-files/github.com
