#!/bin/bash
set -e

docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD" "$DOCKER_SERVER"
find . -name 'Dockerfile' -print0 |
    while IFS= read -r -d '' line; do
        name=$(echo "$line" | awk -F'/' '{print $2}')
        tag=$(echo "$line" | awk -F'/' '{print $3}')
        pushd "$name/$tag"
        fullname="$DOCKER_IMAGE_PREFIX$name:$tag"
        echo fullname "$fullname"
        result=0
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "$fullname" >/dev/null 2>&1 || result=$?
        if [ $result -ne 0 ]; then
          docker build -t "$fullname" .
          docker push "$fullname"
        fi
        popd
    done
