# Protoc container image with GRPC plugins for Go and Python

This repo contains a Dockerfile for building a container image suitable for the effortless generation of language bindings from `.proto` files.

The container image contains the following software components:

* [protoc](https://github.com/protocolbuffers/protobuf)
* [protoc-gen-go](https://github.com/protocolbuffers/protobuf-go)
* [protoc-gen-go-grpc](https://github.com/protocolbuffers/protobuf-go)
* [grpcio-tools](https://pypi.org/project/grpcio-tools/)
* [protoc-gen-doc](https://github.com/pseudomuto/protoc-gen-doc)

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
| `22.1__1.28.1`  | `1.2.0`              | `1.51.1`       |

## Build

```bash
./run.sh build
```

```bash
# push images
./run.sh push
```

## Usage

### Go

```bash
docker run -v $(pwd):/in \
  -v $(pwd)/proto:/in/github.com/openconfig/gnmi/proto \
  ghcr.io/srl-labs/protoc:${IMAGE_TAG} ash -c "protoc -I .:/protobuf/include --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative,require_unimplemented_servers=false proto/gnmi/gnmi.proto"
```

### Python

```bash
docker run -v $(pwd):/in \
  -v $(pwd)/proto:/in/github.com/openconfig/gnmi/proto \
  ghcr.io/srl-labs/protoc:${IMAGE_TAG} ash -c "python3 -m grpc_tools.protoc -I ".:/protobuf/include" --python_out=. --grpc_python_out=. proto/gnmi/gnmi.proto"
```
