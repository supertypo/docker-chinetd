#!/bin/sh

REPO_URL=https://github.com/chinet-project/chinet-core

VERSION=$1
CHINET_VERSION=$(echo $VERSION | grep -oP ".*(?=_.+)")
PUSH=$2

set -e

if [ -z "$VERSION" -o -z "$CHINET_VERSION" ]; then
  echo "Usage ${0} <chinet-version_buildnr> [push]"
  echo "Example: ${0} v1.5.0_1"
  exit 1
fi

docker build --pull --build-arg VERSION=${CHINET_VERSION} --build-arg REPO_URL=${REPO_URL} -t supertypo/chinetd:${VERSION} $(dirname $0)
docker tag supertypo/chinetd:${VERSION} supertypo/chinetd:latest

if [ "$PUSH" = "push" ]; then
  docker push supertypo/chinetd:${VERSION}
  if [ "$REPO_URL" = "$REPO_URL_STABLE" ]; then
    docker push supertypo/chinetd:latest    
  fi
fi

