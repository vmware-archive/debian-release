FROM eespino/ubuntu:18.04

RUN apt-get update && \
    apt-get install -y software-properties-common \
                   debmake \
                   equivs \
                   git

WORKDIR /tmp

RUN git clone --branch 5X_STABLE https://github.com/greenplum-db/gpdb.git && \
    git clone https://github.com/greenplum-db/debian-release.git && \
    git clone --branch v3.23.0   https://github.com/greenplum-db/gporca.git gpdb/gporca && \
    git clone --branch v3.1.2-p1 https://github.com/greenplum-db/gp-xerces.git gpdb/gp-xerces

COPY ./debian/ /tmp/gpdb/debian/

WORKDIR /tmp/gpdb

RUN . /etc/os-release && dch --create -M --package gpdb-oss -v $(./getversion --short)-ubuntu-${VERSION_ID} "Test release" --distribution ${VERSION_CODENAME} && \
    yes | mk-build-deps -i debian/control

RUN DEB_BUILD_OPTIONS='nocheck parallel=6' debuild -us -uc -b

RUN echo The debian package is at /tmp/gpdb-oss_$(./getversion --short).build.dev_amd64.deb

WORKDIR /tmp
