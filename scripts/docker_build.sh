#!/bin/bash

set -eoux pipefail

cd "$(dirname "$0")"
source ./vars.sh

# Variables to be set:
# $CACHE_DIR
# $IMAGE
# $PREBUILD_COMMAND
# $BINARY_NAME
function docker_build() {
	case "$IMAGE" in
	*arm | *arm64)
	containerID=$(docker buildx create -it -v $HOME/$CACHE_DIR:/ccache $IMAGE)
	# HACK: We can leverage the same VMs we use to make x86 builds but in expense of using QEMU
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker start $containerID
	docker exec $containerID mkdir /src

	function exec() {
		docker exec $containerID bash -c "$@"
	}

		docker cp ../. $containerID:/src
		exec "$PREBUILD_COMMAND/src/lib/node/build.sh"
		exec "cd /src && npm rebuild"
		exec "cd /src && npm test"
		docker cp $containerID:/src/lib/node/out/Release/node ../build/$PACKAGE_VERSION/$BINARY_NAME
		;;
	*)
	containerID=$(docker create -it -v $HOME/$CACHE_DIR:/ccache $IMAGE)
	docker start $containerID
	docker exec $containerID mkdir /src

	function exec() {
		docker exec $containerID bash -c "$@"
	}

		docker cp ../. $containerID:/src
		exec "$PREBUILD_COMMAND/src/lib/node/build.sh"
		exec "cd /src && npm rebuild"
		exec "cd /src && npm test"
		docker cp $containerID:/src/lib/node/out/Release/node ../build/$PACKAGE_VERSION/$BINARY_NAME
		;;
	esac
}

if [[ "$TARGET" == "alpine" ]]; then
	CACHE_DIR=".ccache-alpine"
	IMAGE="codercom/nbin-alpine"
	PREBUILD_COMMAND=""
	BINARY_NAME="node-${NODE_VERSION}-alpine-x64"
	docker_build
elif [[ "$TARGET" == "aarch64-alpine" ]]; then
	CACHE_DIR=".ccache-alpine"
	IMAGE="codercom/nbin-alpine-aarch64-alpine"
	PREBUILD_COMMAND=""
	BINARY_NAME="node-${NODE_VERSION}-alpine-aarch64"
	docker_build
elif [[ "$TARGET" == "armv7hf-alpine" ]]; then
	CACHE_DIR=".ccache-alpine"
	IMAGE="codercom/nbin-alpine-armv7hf-alpine"
	PREBUILD_COMMAND=""
	BINARY_NAME="node-${NODE_VERSION}-alpine-armv7hf"
	docker_build
elif [[ "$TARGET" == "aarch64" ]]; then
	CACHE_DIR=".ccache-aarch64"
	IMAGE="codercom/nbin-aarch64"
	PREBUILD_COMMAND=""
	BINARY_NAME="node-${NODE_VERSION}-aarch64"
	docker_build
elif [[ "$TARGET" == "armv7hf" ]]; then
	CACHE_DIR=".ccache-armv7hf"
	IMAGE="codercom/nbin-armv7hf"
	PREBUILD_COMMAND=""
	BINARY_NAME="node-${NODE_VERSION}-armv7hf"
	docker_build
else
	CACHE_DIR=".ccache-centos"
	IMAGE="codercom/nbin-centos"
	PREBUILD_COMMAND="source /opt/rh/devtoolset-6/enable &&"
	BINARY_NAME="node-${NODE_VERSION}-linux-x64"
	docker_build
fi

