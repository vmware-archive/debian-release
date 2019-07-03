FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y software-properties-common \
                   debmake \
                   equivs \
                   git

WORKDIR /tmp

RUN git clone https://github.com/greenplum-db/gpdb.git && \
    git clone https://github.com/greenplum-db/debian-release.git && \
    git clone https://github.com/greenplum-db/gporca.git gpdb/gporca && \
    git clone https://github.com/facebook/zstd.git gpdb/gpzstd

COPY ./debian/ /tmp/gpdb/debian/

WORKDIR /tmp/gpdb

RUN git checkout "6X_STABLE" && \
    cd gpzstd && git checkout v1.3.7

RUN dch --create -M --package greenplum-database -v $(./getversion --short) "Test release" && \
    yes | mk-build-deps -i debian/control && \
	DEB_BUILD_OPTIONS='nocheck parallel=6' debuild -us -uc -b

RUN echo The debian package is at /tmp/greenplum-database_$(./getversion --short).build.dev_amd64.deb

WORKDIR /tmp
