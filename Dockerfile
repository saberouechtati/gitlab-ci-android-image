#
# GitLab CI: Android v1
#

FROM ubuntu:18.04
MAINTAINER Saber Ouechtati <saberouechtati@gmail.com>

ENV VERSION_SDK_TOOLS "25.2.2"
ENV VERSION_BUILD_TOOLS "25"
ENV VERSION_TARGET_SDK "25"

ENV SDK_PACKAGES "build-tools-${VERSION_BUILD_TOOLS},android-${VERSION_TARGET_SDK},addon-google_apis-google-${VERSION_TARGET_SDK},platform-tools,extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository"

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
      curl \
      bzip2 \
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
    
ADD http://dl.google.com/android/repository/tools_r${VERSION_SDK_TOOLS}-linux.zip /tools.zip
RUN sudo unzip /tools.zip -d /sdk && \
    sudo rm -v /tools.zip

RUN sudo mkdir -p /root/.android && \
  sudo touch /root/.android/repositories.cfg

RUN (while [ 1 ]; do sleep 5; echo y; done) | sudo ${ANDROID_HOME}/tools/android update sdk -u -a -t ${SDK_PACKAGES}

# RUN sudo curl -L https://services.gradle.org/distributions/gradle-4.10.1-all.zip -o gradle-4.10.1-all.zip
# RUN sudo unzip gradle-4.10.1-all.zip
# ENV GRADLE_HOME=/app/gradle-4.10.1
# ENV PATH=$PATH:$GRADLE_HOME/bin
ADD https://services.gradle.org/distributions/gradle-4.10.1-all.zip gradle-4.10.1-all.zip
RUN sudo mkdir /opt/gradle
RUN sudo unzip -d /opt/gradle gradle-4.10.1-all.zip
RUN export PATH=$PATH:/opt/gradle/gradle-4.10.1/bin
Run echo $PATH
RUN gradle -v
