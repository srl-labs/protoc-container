# Protoc container image with GRPC plugins for Go and Python

This repo contains a Dockerfile for building an image used to generate language-specific bindings from [Nokia SR Linux NDK source `.proto` files](https://github.com/nokia/srlinux-ndk-protobufs).

Protoc and gRPC plugin versions are set in the Dockerfile.

## Build

```bash
IMAGE_TAG=0.0.2
docker build -t ghcr.io/srl-labs/protoc:${IMAGE_TAG} .
docker tag ghcr.io/srl-labs/protoc:${IMAGE_TAG} ghcr.io/srl-labs/protoc:latest
```

```bash
# push images
docker push ghcr.io/srl-labs/protoc:${IMAGE_TAG}
docker push ghcr.io/srl-labs/protoc:latest
```

## Go

```bash
docker run -v $(pwd)/proto:/in -v $(pwd)/ndk:/out ghcr.io/srl-labs/protoc \
  bash -c "protoc --go_out=paths=source_relative:/out --go-grpc_out=paths=source_relative:/out *.proto"
```

## Python

```bash
docker run -v $(pwd)/proto:/in -v $(pwd)/ndk:/out ghcr.io/srl-labs/protoc \
  bash -c "python3 -m grpc_tools.protoc -I /in --python_out=/out --grpc_python_out=/out *.proto"
```
