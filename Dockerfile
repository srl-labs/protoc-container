FROM golang:1.18-alpine as go-grpc-builder
ENV PROTOC_GEN_GO_GRPC_VERSION=1.2.0 \
    GOBIN=/out

RUN mkdir /out
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${PROTOC_GEN_GO_GRPC_VERSION}



FROM ubuntu:22.04
RUN apt update && apt install -y curl unzip python3 python3-distutils

# protobuf releases - https://github.com/protocolbuffers/protobuf/releases
ENV PROTOBUF_VERSION=21.12 \
    PROTOC_GEN_GO_VERSION=1.28.1 \
    PYTHON_GRPCIO_TOOLS_VERSION=1.51.1 \
    OUTDIR=/out

RUN mkdir /protobuf && mkdir /in && mkdir /out

# Protoc compiler installation
RUN curl -NL -o /tmp/protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip && unzip -d /protobuf /tmp/protoc.zip

# protoc-gen-go installation
RUN curl -NL https://github.com/protocolbuffers/protobuf-go/releases/download/v${PROTOC_GEN_GO_VERSION}/protoc-gen-go.v${PROTOC_GEN_GO_VERSION}.linux.amd64.tar.gz | tar xvz -C /protobuf

# protoc-gen-go-grpc installation
RUN curl -NL https://github.com/protocolbuffers/protobuf-go/releases/download/v${PROTOC_GEN_GO_VERSION}/protoc-gen-go.v${PROTOC_GEN_GO_VERSION}.linux.amd64.tar.gz | tar xvz -C /protobuf

RUN install /protobuf/bin/protoc /protobuf/protoc-gen-go /usr/bin && rm -rf /protobuf

# copy protoc-gen-go-grpc
COPY --from=go-grpc-builder /out/ /usr/bin/

# install grpcio-tools for python grpc generation
RUN curl -L -o /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && python3 /tmp/get-pip.py && rm -f /tmp/get-pip.py && pip3 install grpcio-tools==${PYTHON_GRPCIO_TOOLS_VERSION}

# create ext_protos directory
RUN mkdir -p /ext_protos/google/protobuf

# download any.proto
RUN curl -L -o /ext_protos/google/protobuf/any.proto https://raw.githubusercontent.com/protocolbuffers/protobuf/v22.0/src/google/protobuf/any.proto

# download descriptor.proto
RUN curl -L -o /ext_protos/google/protobuf/descriptor.proto https://raw.githubusercontent.com/protocolbuffers/protobuf/v22.0/src/google/protobuf/descriptor.proto

WORKDIR /in