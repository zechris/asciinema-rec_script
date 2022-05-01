# hadolint ignore=DL3006
FROM frolvlad/alpine-bash
RUN apk add --no-cache asciinema=2.0.2-r5 make=4.3-r0

COPY bin/asciinema-rec_script bin/upload.sh /app/bin/
COPY Makefile version.txt /app/

WORKDIR /app

ENV TERM=xterm

ARG VERSION=1.0.0

ENTRYPOINT ["make"]
