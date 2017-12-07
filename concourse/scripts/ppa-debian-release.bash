#!/bin/bash

set -euo pipefail

DEBIAN_RELEASE_DIR="debian_release"
GPDB_SRC_DIR="gpdb"
GPDB_VERSION_LONG=$(${GPDB_SRC_DIR}/getversion)
GPDB_VERSION_SHORT=$(${GPDB_SRC_DIR}/getversion --short)

gpg --import <(echo "$GPG_PRIVATE_KEY")

set -x

# depends on debmake and other tools being available already in image

# Regex to capture required gporca version and download gporca source
ORCA_TAG=$(grep -Po 'v\d+.\d+.\d+' ${GPDB_SRC_DIR}/depends/conanfile_orca.txt)
git clone --branch ${ORCA_TAG} https://github.com/greenplum-db/gporca.git ${GPDB_SRC_DIR}/gporca

mv ${DEBIAN_RELEASE_DIR}/debian ${GPDB_SRC_DIR}/

# Create a changelog
pushd ${GPDB_SRC_DIR}
    echo $(git rev-parse --short HEAD) > BUILD_NUMBER
    dch --create --package greenplum-db-oss -v ${GPDB_VERSION_SHORT}  "${RELEASE_MESSAGE}"
    dch -r "ignored message"
popd

tar czf greenplum-db-oss_${GPDB_VERSION_SHORT}.orig.tar.gz ${GPDB_SRC_DIR}

# Generate source.changes file
pushd ${GPDB_SRC_DIR}
    debuild -S -sa
popd

# Upload source.changes and source.tar.gz to PPA repository
dput ${PPA_REPO} greenplum-db-oss_${GPDB_VERSION_SHORT}_source.changes >/dev/null

echo "Finished Uploading"
echo "Greenplum short version: $GPDB_VERSION_SHORT"
echo "Greenplum long version:  $GPDB_VERSION_LONG"
