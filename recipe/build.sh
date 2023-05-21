#!/bin/sh

set -eux

# https://github.com/stern/stern/blob/v1.25.0/.goreleaser.yaml#L7-L9
LDFLAGS="-X github.com/stern/stern/cmd.version=$PKG_VERSION-$PKG_BUILDNUM"

go build -v -ldflags="$LDFLAGS" -o $PREFIX/bin/stern .

# Cross-compilation: check correct architecture was built
if [ -n "$GOARCH" ]; then
  if [ "$GOOS" = darwin ]; then
    if [ "$GOARCH" = arm64 ]; then
      PATTERN="Mach-O.+arm64"
    else
      PATTERN="Mach-O.+x86_64"
    fi
  else
    if [ "$GOARCH" = arm64 ]; then
      PATTERN="ELF.+aarch64"
    else
      PATTERN="ELF.+x86-64"
    fi
  fi

  file $PREFIX/bin/stern | grep -E "$PATTERN"
fi

go-licenses save . --save_path=./license-files
test -d license-files/github.com
