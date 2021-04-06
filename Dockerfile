FROM node:alpine as build-node

RUN apk add --no-cache git make

RUN git clone https://github.com/mattermost/focalboard.git /usr/src/focalboard

WORKDIR /usr/src/focalboard

RUN make prebuild && make webapp


FROM golang:alpine as build-go

RUN apk add --no-cache make gcc musl-dev

WORKDIR /usr/src/focalboard

COPY --from=build-node /usr/src/focalboard .

RUN make server-linux && \
    mkdir -p /opt/focalboard/bin && \
    mv bin/linux/focalboard-server /opt/focalboard/bin && \
    mv webapp/pack /opt/focalboard && \
    mv server-config.json /opt/focalboard/config.json && \
    mv build/MIT-COMPILED-LICENSE.md /opt/focalboard && \
    mv NOTICE.txt /opt/focalboard && \
    mv webapp/NOTICE.txt /opt/focalboard/webapp-NOTICE.txt


FROM alpine:latest

WORKDIR /opt/focalboard

COPY --from=build-go /opt/focalboard .

EXPOSE 8000

CMD ["./bin/focalboard-server"]
