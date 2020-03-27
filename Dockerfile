FROM alpine:3.11.5

ADD dependencies.tar.gz /tmp
ADD hbase-bin /opt

RUN touch repo.list && \
    find /tmp/dependencies/* -exec apk add --repositories-file=repo.list --allow-untrusted --no-network --no-cache {} + && \
    rm -rf repo.list /tmp/dependencies && \
    cd opt && \
    cat hbase-2.1.4-bin.tar.gz.part-* | tar -xvzf - && \
    rm -rf hbase-2.1.4-bin.tar.gz.part-* && \
    mv hbase-2.1.4 hbase && \
    cd hbase && \
    rm -rf docs *.md *.txt *.cmd LEGAL && \
    ln -sf /opt/hbase/bin/* /usr/bin

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

ADD ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["bash", "entrypoint.sh"]
