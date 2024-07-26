FROM fedora:latest

ARG userid
ARG groupid
ARG username
#
RUN  dnf -y update \
#  && dnf -y install bash coreutils bzip2 curl java-1.8.0-openjdk java-1.8.0-openjdk-devel unzip zip zlib \
#  && dnf -y install @development-tools tini android-tools automake bc bison  bzip2-libs ccache
   && dnf -y install @development-tools android-tools automake bc bison bzip2 bzip2-libs ccache curl dpkg-dev flex gcc gcc-c++ git git-lfs glibc-devel.{x86_64,i686} gnupg gperf ImageMagick ImageMagick-c++-devel ImageMagick-devel java-1.8.0-openjdk java-1.8.0-openjdk-devel libgcc.{x86_64,i686} libstdc++.{x86_64,i686} libX11-devel.{x86_64,i686} libxml2-devel libXrandr.{x86_64,i686} libXrender.{x86_64,i686} libxslt lz4-libs lzop make maven mesa-libGL-devel.{x86_64,i686} ncurses ncurses-compat-libs ncurses-devel.{x86_64,i686} ninja-build openssl-devel optipng jpegoptim perl perl-Digest-MD5-File perl-Switch pngcrush python python2 python3-virtualenv python3 python3-mako python-mako python-markdown python-networkx readline-devel.{x86_64,i686} rsync schedtool SDL squashfs-tools syslinux-devel unzip wxGTK xml2 xz-lzma-compat zip zlib zlib-devel vim-common vboot-utils mozilla-fira-mono-fonts mozilla-fira-sans-fonts openssl nano htop wget libxcrypt-compat.x86_64 golang \
  && dnf clean all \
  && curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo \
  && chmod a+x /usr/local/bin/repo   \
  && sudo ln -sf /usr/share/crypto-policies/LEGACY/java.txt /etc/crypto-policies/back-ends/java.config

RUN git clone https://github.com/rfjakob/gocryptfs.git \
 && cd gocryptfs \
 && ./build-without-openssl.bash
RUN cp $(go env GOPATH | cut -f1 -d:)/bin/gocryptfs /usr/local/bin/

RUN groupadd --non-unique --gid $groupid $username \
 && useradd --create-home --shell /bin/bash --uid $userid --gid $groupid $username \
 && echo $username >/root/username \
 && echo "export USER="$username >>/home/$username/.gitconfig

COPY gitconfig /home/$username/.gitconfig
RUN mkdir -p /home/$username/android \
 && mkdir -p /home/$username/.ccache \
 && chown $userid:$groupid /home/$username/.gitconfig /home/$username/android /home/$username/.ccache

COPY phase-*.sh /home/$username/

ENV HOME=/home/$username
ENV USER=$username
ENV USE_CCACHE=1
ENV CCACHE_COMPRESS=1
ENV CCACHE_COMPRESSLEVEL=1
ENV CCACHE_EXEC=/usr/bin/ccache
ENV CCACHE_DIR=/home/$username/.ccache
ENTRYPOINT chroot --userspec=$(cat /root/username):$(cat /root/username) --skip-chdir / /bin/bash -i
