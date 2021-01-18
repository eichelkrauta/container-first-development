FROM alpine:3.13.0

RUN apk add --update nodejs npm

COPY index.js /code/index.js
WORKDIR /code
