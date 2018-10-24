#!/bin/bash -ex
mkdir -p "$HOME/.ccache"
docker run --env-file .travis/common/travis-ci.env -v $(pwd):/citra -v "$HOME/.ccache":/root/.ccache -v /tmp:/tmp --privileged citraemu/build-environments:linux-fresh /bin/bash -ex /citra/.travis/linux-flatpak/docker.sh
