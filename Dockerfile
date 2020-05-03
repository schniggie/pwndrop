FROM lsiobase/alpine:3.11 as buildstage

# build variables
ARG PWNDROP_RELEASE

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache \
	curl \
	g++ \
	gcc \
	git \
	go \
	tar

RUN \
echo "**** fetch source code ****" && \
 cd /tmp && \
 git clone \
	"https://github.com/schniggie/pwndrop" && \
 cd /tmp/pwndrop && \
 go build -ldflags="-s -w" \
	-o /app/pwndrop/pwndrop \
	-mod=vendor \
	main.go && \
 cp -r ./www /app/pwndrop/admin

############## runtime stage ##############
FROM lsiobase/alpine:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PWNDROP_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# add pwndrop
COPY --from=buildstage /app/pwndrop/ /app/pwndrop/

# add local files
COPY /root /

# ports and volumes
EXPOSE 53 80 443
