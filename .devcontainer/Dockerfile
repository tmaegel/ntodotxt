FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="3.24.5"
ENV FLUTTER_HOME="/home/vscode/flutter"
ENV ANDROID_HOME="/home/vscode/.android-sdk"
ENV ANDROID_USER_HOME="/home/vscode/.android"
ENV ANDROID_PLATFORM_VERSION="36"
ENV ANDROID_BUILD_TOOLS_VERSION="36.0.0"
ENV ANDROID_SYSTEM_IMAGE="system-images;android-${ANDROID_PLATFORM_VERSION};google_apis;x86_64"
ENV DEBIAN_FRONTEND="noninteractive"
ENV PATH=${PATH}:${FLUTTER_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	clang \
	cmake \
	curl \
	dconf-gsettings-backend \
	dconf-service \
	gsettings-desktop-schemas \
	libcanberra-gtk-module \
	libgl1-mesa-dri \
	libglu1-mesa \
	libgtk-3-dev \
	liblzma-dev \
	libpulse-dev \
	libsecret-1-dev \
	libsqlite3-dev \
	libstdc++-12-dev \
	libx11-xcb1 \
	libxcb-cursor0 \
	libxcb-xinerama0 \
	libxkbcommon-x11-0 \
	libxkbfile-dev \
	ninja-build \
	openjdk-17-jdk-headless \
	pkg-config \
	unzip \
	vim \
	wget \
	xdg-user-dirs \
	xz-utils \
	zip && \
	apt-get clean -y && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${ANDROID_USER_HOME} ${ANDROID_HOME}/cmdline-tools && \
	wget "https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip" -O commandlinetools.zip && \
	unzip commandlinetools.zip -d ${ANDROID_HOME}/cmdline-tools && \
	mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
	rm commandlinetools.zip

RUN yes | sdkmanager --licenses && \
	sdkmanager --update && \
	sdkmanager platform-tools && \
	sdkmanager emulator && \
	sdkmanager "platforms;android-${ANDROID_PLATFORM_VERSION}" && \
	sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
	sdkmanager "${ANDROID_SYSTEM_IMAGE}" && \
	echo | avdmanager create avd -n android-${ANDROID_PLATFORM_VERSION} -k "${ANDROID_SYSTEM_IMAGE}"

RUN chown -R vscode:vscode ${ANDROID_HOME} && \
	chown -R vscode:vscode ${ANDROID_USER_HOME}

RUN mkdir -p ${FLUTTER_HOME} && \
	wget "https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz" \
		-O flutter.tar.xz && \
    tar xf flutter.tar.xz -C ${FLUTTER_HOME} --strip-components=1 && \
    rm flutter.tar.xz && \
	chown -R vscode:vscode ${FLUTTER_HOME}

USER vscode

RUN dart --disable-analytics && flutter --disable-analytics
