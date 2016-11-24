# homeblocks.net v2
(Homeblocks with Vert.X and Ceylon)

_Build your homepage, block after block_

## Ceylon: compile and run

```bash
ceylon run --compile net.homeblocks.server
```

## Docker

Note: the main Dockerfile is based on an intermediate image "homeblocks-cache" aiming to provide ceylon cache independently from the main image, to accelerate builds on source change.

### Cache

Note that buiding the cache is not mandatory, it just speeds up the build.

Modify docker-cache/source/net/homeblocks/cache/module.ceylon to reflect any modification of the external dependencies.

```bash
cd docker-cache
docker build -t jotak/homeblocks-cache .
```

(It may take a while, ceylon will download all dependencies)

### Main image

```bash
docker build -t jotak/homeblocks .
docker run -i -p 8081:8081 --name homeblocks --rm jotak/homeblocks

# Run with secrets and users volumes in current directory:
docker run -i -p 8081:8081 -v `pwd`/secrets:/app/secrets -v `pwd`/users:/app/users --name homeblocks --rm jotak/homeblocks
```
