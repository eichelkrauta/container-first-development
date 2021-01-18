# Container-First Development
This is the code project used in conjunction with the Container-First
Development presentation.

## Reset
```
# Todo: this could probably be better...
docker system prune -a -f
```

## 01:
Show that `nodejs index.js` produces the text 'Hello World!'

To start the project over from scratch, you'll at least need
to have NodeJS installed locally :)

## 02:
- Add a `Dockerfile` that pulls from alpine linux and have it
add developer dependencies: NodeJS and NPM
```
FROM alpine:3.13.0

RUN apk add --update nodejs npm
```
- Manually insert the `index.js` into the container
```
COPY index.js /code/index.js
WORKDIR /code
```

- Build a docker image using `docker build . -t dev-image`

- Show that we can start the dev-image and shell into it using
`docker run -it --rm dev-image sh` and then `node index.js`

