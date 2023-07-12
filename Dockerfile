FROM golang:1.20.6 as builder

WORKDIR /go/src/github.com/prometheus/mysqld_exporter

COPY go.mod go.sum ./
RUN go mod download
COPY collector ./collector
COPY .promu.yml .promu.yml
COPY Makefile Makefile
COPY Makefile.common Makefile.common
COPY mysqld_exporter.go mysqld_exporter.go
RUN make build
RUN cp mysqld_exporter /bin/mysqld_exporter

FROM scratch as scratch
COPY --from=builder /bin/mysqld_exporter /bin/mysqld_exporter
EXPOSE      9104
USER        59000:59000
ENTRYPOINT  [ "/bin/mysqld_exporter" ]

FROM quay.io/sysdig/sysdig-mini-ubi:1.4.11 as ubi
COPY --from=builder /bin/mysqld_exporter /bin/mysqld_exporter
EXPOSE      9104
USER        nobody
ENTRYPOINT  [ "/bin/mysqld_exporter" ]