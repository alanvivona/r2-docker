# Custom r2 docker build 
# ========
# ubuntu
# nodejs
# python pip
# r2
# r2pipe
# r2frida
# r2dec
#
# Takes your custom config file (.radare2rc) from the current directory
# Copies contents of ./data to /home/r2/data
#
# Build docker image with:
# $ docker build -t r2-docker:latest .
#
# Open binary with frida:
# r2 frida:///home/r2/data/sample

# Using Ubuntu latest as base image.
FROM ubuntu:latest

# Label base
LABEL r2-docker=latest

ARG R2_TAG=5.9.8

# Build and install radare2 on master branch
RUN DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386 && apt-get update

# Build dependencies
RUN apt-get install -y \
  curl \
  gcc \
  git \
  bison \
  pkg-config \
  make \
  glib-2.0 \
  libc6:i386 \
  libncurses6:i386 \
  libstdc++6:i386 \
  gnupg2 \
  vim \
  sudo \
  xz-utils \
  python3-pip \
  pipx \
  python-is-python3 \
  openssl \
  build-essential \
  ninja-build \
  meson \
  xxd \
  wget \
  tmux \
  unzip

# nodejs
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get update
RUN apt-get install nodejs

# r2pipe
RUN pip3 install --break-system-packages r2pipe && npm install --unsafe-perm -g r2pipe

# Build radare2 in a volume to minimize space used by build
#VOLUME ["/mnt"]
#WORKDIR /mnt
# r2
RUN git clone -q --depth 1 https://github.com/radare/radare2.git -b ${R2_TAG}  && \
    ./radare2/sys/install.sh
  
# Create non-root user
RUN useradd -m r2 && adduser r2 sudo

# New added for disable sudo password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Initilise base user
USER r2
WORKDIR /home/r2
ENV HOME=/home/r2

# Setup r2pm
RUN r2pm -U
# RUN r2pm -U && chown -R r2:r2 /home/r2/.config

# r2dec plugin
# command pdd
# .radare2rc options:
#   r2dec.casts         | if false, hides all casts in the pseudo code.
#   r2dec.asm           | if true, shows pseudo next to the assembly.
#   r2dec.blocks        | if true, shows only scopes blocks.
#   r2dec.paddr         | if true, all xrefs uses physical addresses compare.
#   r2dec.xrefs         | if true, shows all xrefs in the pseudo code.
#   r2dec.theme         | defines the color theme to be used on r2dec.
#   e scr.html          | outputs html data instead of text.
#   e scr.color         | enables syntax colors.
RUN r2pm -i r2dec

# r2frida plugin
# Forms of use:
# $ r2 frida://Twitter
# $ r2 frida://1234
# $ r2 frida:///bin/ls
# $ r2 frida://"/bin/ls -al"
# $ r2 frida://device-id/Twitter
RUN r2pm -i r2frida

# r2ghidra plugin
RUN r2pm -i r2ghidra r2ghidra-sleigh 

# Cleanup
USER root
RUN apt-get autoremove --purge -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Base command for container
USER r2
COPY .radare2rc /home/r2/.radare2rc
COPY ./data /home/r2/data
COPY .tmux.conf ${HOME}/.tmux.conf

ENTRYPOINT ["bash"]
