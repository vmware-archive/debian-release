#!/bin/bash

set -euo pipefail

DEBIAN_RELEASE_DIR="debian_release"
GPDB_SRC_DIR="gpdb"
GPDB_VERSION=$(${GPDB_SRC_DIR}/getversion --short)

gpg --import <(echo "$GPG_PRIVATE_KEY")

set -x

sed -i "s/\[Greenplum Database\], \[.*\], \[support@greenplum.org\]/\[Greenplum Database\], \[${GPDB_VERSION}\], \[support@greenplum.org\]/" ${GPDB_SRC_DIR}/configure.in
autoconf
echo $(git rev-parse --short HEAD) > ${GPDB_SRC_DIR}/BUILD_NUMBER

# depends on debmake and other tools being available already in image

# Regex to capture required gporca version and download gporca source
ORCA_TAG=$(grep -Po 'v\d+.\d+.\d+' ${GPDB_SRC_DIR}/depends/conanfile_orca.txt)
git clone --branch ${ORCA_TAG} https://github.com/greenplum-db/gporca.git ${GPDB_SRC_DIR}/gporca

mv ${DEBIAN_RELEASE_DIR}/debian ${GPDB_SRC_DIR}/

# Create a changelog
pushd ${GPDB_SRC_DIR}
    dch --create --package greenplum-db-oss -v ${GPDB_VERSION}  "${RELEASE_MESSAGE}"
    dch -r "ignored message"
popd

tar czf greenplum-db-oss_${GPDB_VERSION}.orig.tar.gz ${GPDB_SRC_DIR}

# Generate source.changes file
pushd ${GPDB_SRC_DIR}
  debuild -S -sa
popd

# Upload source.changes and source.tar.gz to PPA repository
dput ${PPA_REPO} greenplum-db-oss_${GPDB_VERSION}_source.changes >/dev/null

echo "Done Upload"
