FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG HYDRA2_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nemchik"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	curl \
	jq \
	unzip && \
 apt-get install --no-install-recommends -y \
	openjdk-11-jre-headless \
	python3 && \
 echo "**** install hydra2 ****" && \
 if [ -z ${HYDRA2_RELEASE+x} ]; then \
	HYDRA2_RELEASE=$(curl -sX GET "https://api.github.com/repos/theotherp/nzbhydra2/releases/latest" \
	| jq -r .tag_name); \
 fi && \
 HYDRA2_VER=${HYDRA2_RELEASE#v} && \
 curl -o \
 /tmp/hydra2.zip -L \
	"https://github.com/theotherp/nzbhydra2/releases/download/v${HYDRA2_VER}/nzbhydra2-${HYDRA2_VER}-linux.zip" && \
 mkdir -p /app/hydra2 && \
 unzip /tmp/hydra2.zip -d /app/hydra2 && \
 curl -o \
 /app/hydra2/nzbhydra2wrapperPy3.py -L \
	"https://raw.githubusercontent.com/theotherp/nzbhydra2/master/other/wrapper/nzbhydra2wrapperPy3.py" && \
 chmod +x /app/hydra2/nzbhydra2wrapperPy3.py && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# copy local files
COPY root/ /
COPY ./config /config

# ports and volumes
EXPOSE $PORT

