FROM golang:1.18-alpine as go-grpc-builder
ARG PROTOC_GEN_GO_GRPC_VERSION=1.2.0
ENV GOBIN=/out

RUN mkdir /out
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${PROTOC_GEN_GO_GRPC_VERSION}


FROM python:3-alpine
RUN apk add curl unzip

# protobuf releases - https://github.com/protocolbuffers/protobuf/releases
ARG PROTOBUF_VERSION=22.1
ARG PROTOC_GEN_GO_VERSION=1.28.1
ARG PYTHON_GRPCIO_TOOLS_VERSION=1.51.1
ARG PROTOC_GEN_DOC_VERSION=1.5.1
ARG PROTOBUF_DEV_VERSION=3.21.9-r0

ENV OUTDIR=/out

RUN mkdir /protobuf && mkdir /in && mkdir /out

# Protoc compiler installation
RUN curl -NL -o /tmp/protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip && unzip -d /protobuf /tmp/protoc.zip

# protoc-gen-go installation
RUN curl -NL https://github.com/protocolbuffers/protobuf-go/releases/download/v${PROTOC_GEN_GO_VERSION}/protoc-gen-go.v${PROTOC_GEN_GO_VERSION}.linux.amd64.tar.gz | tar xvz -C /protobuf

# protoc-gen-go-grpc installation
RUN curl -NL https://github.com/protocolbuffers/protobuf-go/releases/download/v${PROTOC_GEN_GO_VERSION}/protoc-gen-go.v${PROTOC_GEN_GO_VERSION}.linux.amd64.tar.gz | tar xvz -C /protobuf

RUN install /protobuf/bin/protoc /protobuf/protoc-gen-go /usr/bin

# copy protoc-gen-go-grpc
COPY --from=go-grpc-builder /out/ /usr/bin/

# install grpcio-tools for python grpc generation
RUN pip3 install grpcio-tools==${PYTHON_GRPCIO_TOOLS_VERSION}

# download protoc-gen-doc
RUN curl -Lo -X GET https://github.com/pseudomuto/protoc-gen-doc/releases/download/v${PROTOC_GEN_DOC_VERSION}/protoc-gen-doc_${PROTOC_GEN_DOC_VERSION}_linux_amd64.tar.gz | tar xvz -C /tmp && mv /tmp/protoc-gen-doc /usr/bin


WORKDIR /in