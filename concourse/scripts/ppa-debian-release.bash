#!/bin/bash

set -euo pipefail

gpg --import <(echo "$GPG_PRIVATE_KEY")

set -x

apt-get update
apt-get install -y software-properties-common \
                   debmake \
                   equivs \
                   git

# Regex to capture required gporca version and download gporca source
ORCA_TAG=$(grep -Po 'v\d+.\d+.\d+' gpdb/depends/conanfile_orca.txt)
git clone --branch ${ORCA_TAG} https://github.com/greenplum-db/gporca.git gpdb/gporca

mv debian-release/debian gpdb/

# Create a changelog
GPDB_VERSION=$(gpdb/getversion --short)
pushd gpdb
    dch --create -M --package greenplum-db-oss -v ${GPDB_VERSION}  "${RELEASE_MESSAGE}"
    dch -M -r "ignored message"
popd

tar czf greenplum-db-oss_${GPDB_VERSION}.orig.tar.gz gpdb

# Generate source.changes file
pushd gpdb
  debuild -S -sa
popd

# Upload source.changes and source.tar.gz to PPA repository
dput ${PPA_REPO} greenplum-db-oss_${GPDB_VERSION}_source.changes >/dev/null

echo "Done Upload"
