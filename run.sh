#!/bin/bash

# usage: ./run.sh <build or push> <image_tag> <latest>
# when <latest> is set to "latest" it will also tag the image as latest
# when latest is not set, it will only tag the image with the image_tag

set -o errexit
set -o pipefail

IMAGE_NAME=ghcr.io/srl-labs/protoc
IMAGE_TAG=$2
LATEST=$3

if [ -z "$2" ]; then
    echo "Usage: $0 <build or push> <image_tag>"
    exit 1
fi

function build {
    echo "Building..."
    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
    if [[ "$LATEST" == "latest" ]]; then
        echo "tagging as latest"
        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
    fi
    
}

function push {
    echo "Pushing..."
    docker push ${IMAGE_NAME}:${IMAGE_TAG}
    if [[ "$LATEST" == "latest" ]]; then
        docker push ${IMAGE_NAME}:latest
    fi
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