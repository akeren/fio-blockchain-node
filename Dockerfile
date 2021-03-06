FROM golang:latest AS health

RUN go get github.com/blockpane/fio-docker/health

FROM ubuntu:18.04

RUN apt-get update; apt-get -y dist-upgrade; apt-get -y install aria2 jq pixz curl && \
    aria2c -x 5 "https://bin.fioprotocol.io/mainnet/fioprotocol-3.1.x-latest-ubuntu-18.04-amd64.deb" && \
    apt-get install -y ./fioprotocol-3.1.x-latest-ubuntu-18.04-amd64.deb && rm -f ./fioprotocol-3.1.x-latest-ubuntu-18.04-amd64.deb && \
    rm -f /etc/fio/nodeos/config.ini  && rm -rf /var/lib/apt/lists/*

COPY /config/config.ini /etc/fio/nodeos/config.ini
COPY fio-run /usr/local/bin/fio-run
COPY --from=health /go/bin/health /usr/local/bin/fio-health
RUN chmod 0755 /usr/local/bin/fio-run

EXPOSE 8888/tcp
EXPOSE 3856/tcp
USER fio
WORKDIR /var/lib/fio

HEALTHCHECK --interval=10s --timeout=2s --start-period=1m CMD fio-health

CMD ["/usr/local/bin/fio-run"]

