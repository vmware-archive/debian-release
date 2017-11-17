#!/bin/bash

set -euo pipefail

gpg --import <(echo "$GPG_PRIVATE_KEY")

set -x

apt-get update
apt-get install -y software-properties-common \
                   debmake \
                   equivs

cp -R gporca/ gpdb/
cp -R debian-release/debian gpdb/

pushd gpdb
    dch --create -M --package greenplum-db-oss -v ${GPDB_TAG}  "${RELEASE_MESSAGE}"
    dch -M -r "ignored message"
popd

tar czf greenplum-db-oss_${GPDB_TAG}.orig.tar.gz gpdb

pushd gpdb
  debuild -S -sa
popd

dput ${PPA_REPO} greenplum-db-oss_${GPDB_TAG}_source.changes >/dev/null

echo "Done Upload"
