#!/bin/bash -e

# Create a snapshot of the libffi repository from github, as a workaround for
# the lack of recent releases of libffi (see https://github.com/libffi/libffi/issues/296)

GVERS=3.99999 # see configure.ac / AC_INIT

# make a temporary directory and perform operations in there.
TMPD=$(mktemp -d)
TDIR=$(pwd)

# clone the repository (shallow is sufficient)
git -C ${TMPD} clone --depth 1 https://github.com/libffi/libffi.git
REPO="${TMPD}/libffi"

# record the revision and create a copy of only the files
# contained in the repository at libffi-<revision>
GHASH=$(git -C ${REPO} rev-parse --short HEAD)
GDATE=$(git -C ${REPO} log -1 --pretty=format:%cd --date=format:%Y%m%d)
SUFFIX="${GVERS}+git${GDATE}+${GHASH}"
git -C ${REPO} archive --format=tar --prefix="libffi-${SUFFIX}/" HEAD | tar -C ${TMPD} -x

# run and remove autogen, so we don't have to run it on the CI or elsewhere
# and as such incure additional dependencies like libtool.
(cd "${TMPD}/libffi-${SUFFIX}" && ./autogen.sh && rm autogen.sh)

# package it up
LIB="libffi-${SUFFIX}.tar.gz"
(cd "${TMPD}" && tar -czf "${LIB}" "libffi-${SUFFIX}")
mv "$TMPD/$LIB" ./$LIB

# create orphan branch
git checkout --orphan "libffi-${SUFFIX}"
git add $LIB
cat >README.md <<EOF
# libffi snapshot tarball for GHC

This source snapshot was produced from
[libffi](https://github.com/libffi/libffi) commit
[${GHASH}](https://github.com/libffi/libffi/commit/${GHASH}) for GHC. See the
\`master\` branch of this repository for more information about the rationale
and tools for producing these snapshots.
EOF
git add README.md
git rm --cached mk-snapshot.sh
git commit -m "Snapshot of libffi ${GHASH}"
git checkout -f master

echo "Created branch libffi-${SUFFIX}"
