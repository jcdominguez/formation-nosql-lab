FROM eclipse-temurin:17-jre-jammy

ARG HBASE_VERSION=2.6.6
ARG HBASE_SHA512=7724703971A397F7B78AA82BEF97EAE6B5FD2FC83A2039D42B4C9CE02F67B192C502CB6CFBF3A0F205F1384871456087AA54B282469E22CABF715AE594076A5D

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl procps \
    && rm -rf /var/lib/apt/lists/*

RUN curl --fail --location --show-error \
      "https://downloads.apache.org/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz" \
      --output /tmp/hbase.tar.gz \
    && echo "${HBASE_SHA512}  /tmp/hbase.tar.gz" | sha512sum --check - \
    && mkdir -p /opt/hbase \
    && tar --extract --gzip --file /tmp/hbase.tar.gz --strip-components=1 --directory /opt/hbase \
    && rm /tmp/hbase.tar.gz \
    && mkdir -p /data/hbase /data/zookeeper

ENV HBASE_HOME=/opt/hbase
ENV PATH="${HBASE_HOME}/bin:${PATH}"

COPY hbase-site.xml /opt/hbase/conf/hbase-site.xml
COPY hbase-entrypoint.sh /usr/local/bin/hbase-entrypoint.sh
COPY hbase-healthcheck.sh /usr/local/bin/hbase-healthcheck.sh

RUN chmod +x /usr/local/bin/hbase-entrypoint.sh /usr/local/bin/hbase-healthcheck.sh

EXPOSE 16010

CMD ["/usr/local/bin/hbase-entrypoint.sh"]
