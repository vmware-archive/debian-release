![Greenplum](/logo/logo-greenplum.png)

The Greenplum Database (GPDB) is an advanced, fully featured, open
source data warehouse. It provides powerful and rapid analytics on
petabyte scale data volumes. Uniquely geared toward big data
analytics, Greenplum Database is powered by the world’s most advanced
cost-based query optimizer delivering high analytical query
performance on large data volumes.

This Debian release of Greenplum project is licensed under the [Apache 2
license](http://www.apache.org/licenses/LICENSE-2.0). We want to thank
all our current community contributors and are really interested in
all new potential contributions. For the Greenplum Database community
no contribution is too small, we encourage all types of contributions.

## Debian Source and Binary Packaging

This documentation assumes that you run the following commands on an Ubuntu platform, and has been tested on Xenial 16.04 (pivotaldata/ubuntu-gpcloud-dev:16.04).

Note: This debian binary install will only copy the necessary files but does not initialize the cluster.

### Requirements

```bash
apt-get update
apt-get install -y software-properties-common \
                   debmake \
                   equivs \
                   git
```

### Download GPDB and GPORCA sources

```bash
git clone https://github.com/greenplum-db/gpdb.git
git clone https://github.com/greenplum-db/debian-release.git
git clone https://github.com/greenplum-db/gporca.git gpdb/gporca
cp -R debian-release/debian gpdb/
```

### Create sample changelog file

For now, there is no `changelog` file that contains history of previous deb releases.
However, we can create one using the following command.

```bash
pushd gpdb
    dch --create -M --package greenplum-db-oss -v <version>  "Release Message"
popd
```

--------------------------------------------------------------------------------
### Debian Packaging
Follow these steps to create a debian package in your local environment.

#### Download build dependencies

In order to create a debian binary, we need all the build dependencies downloaded prior to building it.
All build dependencies are listed in `gpdb/debian/control` file.

```bash
pushd gpdb
    yes | mk-build-deps -i debian/control
popd
```

#### Creating a binary Greenplum debian package

Use `debuild` utility to create greenplum debian binary

```bash
pushd gpdb
    DEB_BUILD_OPTIONS='nocheck parallel=6' debuild -us -uc -b
popd
```
--------------------------------------------------------------------------------
### Debian Packaging in PPA

Follow these steps to create a debian package in Launchpad Personal Packaging Archive (PPA).
(Note: the Greenplum database only support 64 bit architectures in the PPA builds.)

#### Create a Release in `changelog`

```bash
pushd gpdb
  dch -M -r "ignored message"
popd
```

NOTE: if the same source must be re-released, the way to do this is to modify the version number. A common way to re-release with new version number would be add this "-i" here: `dch -i`

#### Create a tar ball of the source code
```bash
tar czf <packagename_version>.orig.tar.gz gpdb
```

#### Create source changes files

Create a source.changes file to upload to PPA repo using `debuild` utility.

Make sure you imported your GPG private key to sign the `source.changes` before
running the following. (See [PPA info](https://help.launchpad.net/YourAccount/ImportingYourPGPKey) about creating a GPG key.)

```bash
pushd gpdb
  debuild -S -sa
popd
```
This creates a `<packagename_version>_source.changes` file.

#### Upload to PPA

```bash
export PPA_REPO=<repo name>
dput ${PPA_REPO} <packagename_version>_source.changes
```
Check your email configured in PPA repo to see if the upload has been `ACCEPTED` or `REJECTED`.

-------------------------------------------------------------------------------
### How to download from the public Greenplum PPA repo

This is a test to the Greenplum debian from downloaded from PPA.

#### Using apt-get to install the binary package

```bash
# if you are on a macos or platform other than debian, docker can help:
docker run --rm -it ubuntu /bin/bash

apt-get update
apt-get install -y software-properties-common
add-apt-repository ppa:greenplum/db
apt-get update
apt-get install -y greenplum-db-oss

source /opt/gpdb/greenplum-path.sh
echo $GPHOME

# server is NOT running yet--you'll need to configure the cluster, etc.
```

#### Using apt-get to download source

```bash
# if you are on a macos or platform other than debian, docker can help:
docker run --rm -it ubuntu /bin/bash

apt-get update
apt-get install -y software-properties-common
add-apt-repository -s ppa:greenplum/db
apt-get update
apt-get install -y greenplum-db-oss
ls greenplum*
```
