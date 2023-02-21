# Protoc container image with GRPC plugins for Go and Python

This repo contains a Dockerfile for building a container image suitable for the effortless generation of language bindings from `.proto` files.

The container image contains the following software components:

* [protoc](https://github.com/protocolbuffers/protobuf)
* [protoc-gen-go](https://github.com/protocolbuffers/protobuf-go)
* [protoc-gen-go-grpc](https://github.com/protocolbuffers/protobuf-go)
* [grpcio-tools](https://pypi.org/project/grpcio-tools/)
* additional proto files that are commonly imported by other proto files:
  * [`any.proto`](https://github.com/protocolbuffers/protobuf/blob/main/src/google/protobuf/any.proto)
  * [`descriptor.proto`](https://github.com/protocolbuffers/protobuf/blob/main/src/google/protobuf/descriptor.proto)

## Versioning

This repo and the container image are tagged with the following versioning scheme:

```bash
# e.g. 21.12__1.28.1
<protoc version>__<protoc-gen-go version>
```

With both `protoc` and `protoc-gen-go` versions clearly stated, it is easy to determine which version of the container image contains which major software components versions used in the generation process.

A version of the gRPC plugins for Go and Python are not included in the tag, and they are provided in the [Dockerfile](Dockerfile) as build arguments. For convenience, they are additionally listed in the table below.

| Repo tag        | `protoc-gen-go-grpc` | `grpcio-tools` |
| --------------- | -------------------- | -------------- |
| `21.12__1.28.1` | `1.2.0`              | `1.51.1`       |

## Build

```bash
IMAGE_TAG=21.12__1.28.1
docker build -t ghcr.io/srl-labs/protoc:${IMAGE_TAG} .
docker tag ghcr.io/srl-labs/protoc:${IMAGE_TAG} ghcr.io/srl-labs/protoc:latest
```

```bash
# push images
docker push ghcr.io/srl-labs/protoc:${IMAGE_TAG}
docker push ghcr.io/srl-labs/protoc:latest
```

## Usage

### Go

```bash
docker run -v $(pwd)/proto:/in -v $(pwd)/ndk:/out ghcr.io/srl-labs/protoc \
  bash -c "protoc --go_out=paths=source_relative:/out --go-grpc_out=paths=source_relative:/out *.proto"
```

### Python

```bash
docker run -v $(pwd)/proto:/in -v $(pwd)/ndk:/out ghcr.io/srl-labs/protoc \
  bash -c "python3 -m grpc_tools.protoc -I /in --python_out=/out --grpc_python_out=/out *.proto"
```
