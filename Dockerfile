FROM openjdk:8-jdk

# Install-time-only environment variables
ARG ANDROID_COMPILE_SDK="28"
ARG ANDROID_BUILD_TOOLS="28.0.0"
# Android SDK tools 26.1.1
ARG ANDROID_SDK_TOOLS="4333796"

# Persistent environment variables
ENV GRADLE_OPTS "-Dorg.gradle.daemon=false"
ENV ANDROID_HOME "/opt/android"
ENV PATH "${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

# Install Android-required packages
RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget unzip lib32stdc++6 lib32z1

# ------------------------------------------------------
# --- Install Android SDKs and other build packages
# ------------------------------------------------------

RUN mkdir /root/.android
RUN touch /root/.android/repositories.cfg
RUN mkdir $ANDROID_HOME
RUN cd $ANDROID_HOME && wget -q -O tools.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip
RUN cd $ANDROID_HOME && unzip tools.zip && rm -f tools.zip

# To get a full list of available artifacts: sdkmanager --list

RUN echo y | sdkmanager "platform-tools"

# Build tools
RUN echo y | sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}"

# SDKs
RUN echo y | sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}"

# Extras
RUN echo y | sdkmanager "extras;android;m2repository"
RUN echo y | sdkmanager "extras;google;m2repository"
RUN echo y | sdkmanager "extras;google;google_play_services"

# Final update
RUN echo y | sdkmanager --update

# ------------------------------------------------------
# --- Cleanup and rev num
# ------------------------------------------------------

# Cleaning
RUN apt-get clean

# Install jq for JSON parsing for releases
RUN apt-get --quiet install --yes jq
