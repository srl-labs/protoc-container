FROM golang:1.21-alpine as go-grpc-builder
# available versions - https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc?tab=versions
ARG PROTOC_GEN_GO_GRPC_VERSION=1.3.0
ENV GOBIN=/out

RUN mkdir /out
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${PROTOC_GEN_GO_GRPC_VERSION}


FROM python:3-alpine
RUN apk add curl unzip

# protobuf (protoc) releases - https://github.com/protocolbuffers/protobuf/releases
ARG PROTOBUF_VERSION=23.3
# protoc-gen-go releases - https://github.com/protocolbuffers/protobuf-go/releases
ARG PROTOC_GEN_GO_VERSION=1.31.0
# grpcio-tools releases - https://pypi.org/project/grpcio-tools/#history
ARG PYTHON_GRPCIO_TOOLS_VERSION=1.56.0
# protoc-gen-doc releases - https://github.com/pseudomuto/protoc-gen-doc/releases
ARG PROTOC_GEN_DOC_VERSION=1.5.1
# googleapis commit - https://github.com/googleapis/googleapis
ARG GOOGLE_APIS_VERSION=5f2465117c6ec4bd8d7b5d23fc8e436608156e64

ENV OUTDIR=/out

RUN mkdir /protobuf && mkdir /in && mkdir /out && mkdir /googleapis

# Protoc compiler installation
RUN curl -NL -o /tmp/protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip && unzip -d /protobuf /tmp/protoc.zip

# protoc-gen-go installation
RUN curl -NL https://github.com/protocolbuffers/protobuf-go/releases/download/v${PROTOC_GEN_GO_VERSION}/protoc-gen-go.v${PROTOC_GEN_GO_VERSION}.linux.amd64.tar.gz | tar xvz -C /protobuf

RUN install /protobuf/bin/protoc /usr/bin

# copy protoc-gen-go-grpc
COPY --from=go-grpc-builder /out/ /usr/bin/

# install grpcio-tools for python grpc generation
RUN pip3 install grpcio-tools==${PYTHON_GRPCIO_TOOLS_VERSION}

# download protoc-gen-doc
RUN curl -Lo -X GET https://github.com/pseudomuto/protoc-gen-doc/releases/download/v${PROTOC_GEN_DOC_VERSION}/protoc-gen-doc_${PROTOC_GEN_DOC_VERSION}_linux_amd64.tar.gz | tar xvz -C /tmp && mv /tmp/protoc-gen-doc /usr/bin

# download googleapis commit 4c3b682f501bb965d34c3d4fc3461edfccf962db
# googleapis does not have a tagged release, so we pin to the latest available at the time
RUN curl -Lo -X GET https://github.com/googleapis/googleapis/archive/${GOOGLE_APIS_VERSION}.tar.gz | tar xvz -C /tmp && mv /tmp/googleapis-${GOOGLE_APIS_VERSION}/* /googleapis


WORKDIR /in