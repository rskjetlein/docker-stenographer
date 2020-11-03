FROM ubuntu:18.04

MAINTAINER rskjetlein@netrunner.nu

RUN apt update && \
    apt install -y \
    tcpdump sudo libaio-dev libleveldb-dev libsnappy-dev libcap-dev \
    libcap2-bin libseccomp-dev gcc make git golang jq openssl

ENV GOPATH=/go

RUN go get github.com/google/stenographer && \
    cd /go/src/github.com/google/stenographer && \
    go build && \
    make -C stenotype && \
    adduser --system --group --no-create-home stenographer && \
    mkdir /etc/stenographer \
          /etc/stenographer/certs \
          /data /data/stenographer \
          /data/stenographer/logs \
          /data/stenographer/index && \
    chown -R root:root /etc/stenographer/certs && \
    chown -R stenographer:stenographer /data/stenographer

COPY stenographer.conf /etc/stenographer/config

RUN chmod 644 /etc/stenographer/config && \
    cd /go/src/github.com/google/stenographer && \
    ./stenokeys.sh stenographer stenographer && \
    install -t /usr/bin stenotype/stenotype && \
    install -t /usr/bin stenocurl && \
    install -t /usr/bin stenoread && \
    install -t /usr/bin stenographer && \
    setcap 'CAP_NET_RAW+ep CAP_NET_ADMIN+ep CAP_IPC_LOCK+ep' /usr/bin/stenotype

# This?
USER stenographer

EXPOSE 1234

CMD ["stenographer", "-syslog=false"]
