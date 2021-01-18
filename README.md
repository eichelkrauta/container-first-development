# Container-First Development
This is the code project used in conjunction with the Container-First
Development presentation.

## Reset
```
# Todo: this could probably be better...
docker system prune -a -f

rm -rf ~/.batect 
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

## 03
- Add batect by copying the [latest](https://github.com/batect/batect/releases)
 release `batect` (Unix) and `batect.cmd` (Windows) to the repository
```
wget -O batect https://github.com/batect/batect/releases/download/0.65.1/batect
wget -O batect.cmd https://github.com/batect/batect/releases/download/0.65.1/batect.cmd
```

- Make sure `batect` is executable
```
chmod +x batect
```

- Run the `batect` CLI to show that batect downloads the platform-specific version
of the CLI automatically `./batect --version`
> This downloads batect to the `~/.batect/caches` directory

- Add a starting `batect.yml` configuration that executes your dev image and prints 'Hello World!'
```
containers:
  build-env:
    build_directory: .

tasks:
  hello:
    description: Starts the build-env
    run:
      container: build-env
      command: sh
```

- Change the `hello` task to use `node /code/index.js` to run the command natively from `batect`.


