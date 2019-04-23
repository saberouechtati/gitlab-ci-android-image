#
# GitLab CI: Android v1
#

FROM ubuntu:18.04
MAINTAINER Saber Ouechtati <saberouechtati@gmail.com>

ENV VERSION_SDK_TOOLS "4333796"

ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools"
ENV DEBIAN_FRONTEND noninteractive

# Create licenses dir
RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo -e "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo -e "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_HOME/licenses/android-sdk-preview-license
  
RUN apt-get -qq update && \
    apt-get install -y -qqy --no-install-recommends \
      sudo
  
RUN adduser --disabled-password --gecos '' docker
RUN adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker

RUN sudo apt-get -qq update && \
    sudo apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-8-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      locales \
    && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
RUN sudo locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN sudo rm -f /etc/ssl/certs/java/cacerts; \
    sudo /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN sudo curl -s https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip > sudo /sdk.zip && \
    sudo unzip /sdk.zip -d /sdk && \
    sudo rm -v /sdk.zip

ADD packages.txt /sdk
RUN sudo mkdir -p /root/.android && \
  sudo touch /root/.android/repositories.cfg && \
  sudo ${ANDROID_HOME}/tools/bin/sdkmanager --update 

RUN sudo while read -r package; do PACKAGES="${PACKAGES}${package} "; done < sudo /sdk/packages.txt && \
    sudo ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}

RUN sudo yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses
