FROM balenalib/armv7hf-debian-node:10.15-jessie-build

RUN ["cross-build-start"]

RUN apt-get update && apt-get -y install build-essential linux-headers-3.16.0-9-all-armhf linux-headers-3.16.0-9-common gcc g++ ccache git make

RUN ["cross-build-end"]
