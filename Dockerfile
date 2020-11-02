FROM golang:alpine3.12

#RUN apk add epel-release
RUN apk add tcpdump sudo libaio-dev leveldb-dev snappy-dev libcap-dev libseccomp-dev \
    g++ glib make git jq which openssl libexecinfo-dev && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk && \
    apk add glibc-2.32-r0.apk

ENV GOPATH=/go

RUN go get github.com/google/stenographer && \
    cd /go/src/github.com/google/stenographer && \
    go build && \
    make -C stenotype && \
    adduser --system --no-create-home stenographer && \
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
