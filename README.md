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

## 04
- Refactor the `Dockerfile` to remove the `index.js` and `WORKDIR`
- Use `batect` to create a volume mount
```
containers:
  build-env:
    build_directory: .
    working_directory: /code
    volumes:
      - container: /code
        local: .

tasks:
  hello:
    description: Runs the 'Hello World' node program
    run:
      container: build-env
      command: node index.js
```
- Run the `./batect hello` and show that 'Hello World!' is still printed on the commandline

## 05
- Create a `shell` command in the `batect.yml` to allow us to shell into the container
```
tasks:
  shell:
    description: Shells into the development container
    run:
      container: build-env
      command: sh
```
- Add this to the configuration of the container:
```
containers:
  build-env:
    run_as_current_user:
      enabled: true
      home_directory: /home/container-user
```
> This prevents the `package-lock.json` from being owned by the root user of the container,
> which will allow us to modify it in later parts of the presentation.

- Shell into the container and run `npm init -y`
> Note: the listener could have easily created a task for this in batect, but I wanted to
> highlight the fact that sometimes, it's nice to snoop around and do manual tasks within
> the container itself; whether for debugging or for one-off tasks.

## 06
- Refactor `index.js` as an express app that shows a page 'Hello World!'
```
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
```

- Run `./batect hello` and show that nodejs is confused about missing dependencies

- Add `express` as a package for the app:
```
npm install --package-lock-only express --save
```

- Add `enable_init_process` to the container configuration to workaround the inability of SIGINT
```
containers:
  build-env:
    enable_init_process: true
```

- We could run `npm install` if we wanted, or we can add it as a prerequisite task 
to be run before `hello`
```
tasks:
  install:
    description: Installs development dependencies to the dev container
    run:
      container: build-env
      command: npm install
```
```
tasks:
  ...
  hello:
    prerequisites:
      - install
```

- Attempt to visit `localhost:3000` and show that no response is happening

- Add the port mapping from the container to host
```
tasks:
  ...
  hello:
    run:
      ports:
        - local: 3000
          container: 3000
```

- Visit the `localhost:3000` site now and see that it shows Hello World!
