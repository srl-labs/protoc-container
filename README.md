This repo contains a dockerfile for building an image that is used to generate language specific binding from [Nokia SR Linux NDK source `.proto` files](https://github.com/nokia/srlinux-ndk-protobufs).

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