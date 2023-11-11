#!/bin/bash

set -o errexit
set -o pipefail

IMAGE_NAME=ghcr.io/srl-labs/protoc
IMAGE_TAG=$2

if [ -z "$2" ]; then
    echo "Usage: $0 <build or push> <image_tag>"
    exit 1
fi

function build {
    echo "Building..."
    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
}

function push {
    echo "Pushing..."
    docker push ${IMAGE_NAME}:${IMAGE_TAG}
    docker push ${IMAGE_NAME}:latest
}

function enter-container {
    docker run --rm -it ${IMAGE_NAME}:${IMAGE_TAG} ash
}

function help {
  printf "%s <task> [args]\n\nTasks:\n" "${0}"

  compgen -A function | grep -v "^_" | cat -n

  printf "\nExtended help:\n  Each task has comments for general usage\n"
}

# This idea is heavily inspired by: https://github.com/adriancooney/Taskfile
TIMEFORMAT=$'\nTask completed in %3lR'
time "${@:-help}"


set -e