FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y software-properties-common \
                   debmake \
                   equivs \
                   git

WORKDIR /tmp

RUN git clone https://github.com/greenplum-db/gpdb.git && \
    git clone https://github.com/greenplum-db/gporca.git gpdb/gporca

COPY ./debian/ /tmp/gpdb/debian/

WORKDIR /tmp/gpdb

RUN git checkout "5X_STABLE"

RUN dch --create -M --package greenplum-db-5 -v $(./getversion --short) "Test release" && \
    yes | mk-build-deps -i debian/control && \
	DEB_BUILD_OPTIONS='nocheck parallel=6' debuild -us -uc -b

RUN echo The debian package is at /tmp/greenplum-db-5_$(./getversion --short).build.dev_amd64.deb

WORKDIR /tmp
