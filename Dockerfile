# NOTE: using Ubuntu 20.04 LTS for updated support for libraries
FROM ubuntu:20.04 AS base

# labels for self documenting details in docker inspect and other tools
LABEL com.msats.us.maintainer=msats.us
LABEL com.msats.us.version=04.19.2021

# NOTE: the noninteractive ARG is needed to by-pass a prompt for alternative timezone during Ubuntu install. 
# Docker uses its container's host system time and calendar by default (but not the timezone, which will default to UTC).
ARG DEBIAN_FRONTEND=noninteractive

# install less, net-tools (for netstat), and vim-tiny on ubuntu image.
RUN apt update \
    && apt install -y \
        dbus-x11 \
        less \
        net-tools \
        software-properties-common \
        vim-tiny \
    && apt autoclean -y \
    && rm -rf /var/lib/apt/lists/*

# copy and prep for running custom scripts and related assets in the container as part of the image build
COPY scripts/test-users-setup.sh /tmp/scripts/

# convention for custom config files as needed
COPY config/etc/msats.d /etc/msats.d/

# run custom script to add test users for the container non-LDAP login
WORKDIR /tmp/scripts
RUN chmod a+x /tmp/scripts/test-users-setup.sh \
    && /tmp/scripts/test-users-setup.sh \
    && rm -frv /tmp/scripts

WORKDIR /tmp/

# install utils and libs to compile latest xrdp from src. 
# See: https://github.com/bitcoin/bitcoin.git
RUN apt update \
    && apt install -y \
     autotools-dev \
     bsdmainutils \ 
     build-essential \
     git \
     libtool \
     pkg-config \ 
     python3 \
     # install other deps for bitcoin
     libboost-dev \
     libboost-system-dev \
     libboost-filesystem-dev \
     libboost-test-dev \
     libevent-dev \
     libqrencode-dev \
    && apt autoclean -y

FROM base as build-bitcoin

# bitcoin compile and install from source: no wallet, no GUI
ENV prefix="/usr"
RUN cd /tmp \
    && git clone --recursive https://github.com/bitcoin/bitcoin.git \
    && cd /tmp/bitcoin \
    && export CFLAGS="-O2 -fstack-protector-strong -Wformat -Werror=format-security" \
    && export LDFLAGS="-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed" \
    && export CPPFLAGS="-Wdate-time -D_FORTIFY_SOURCE=2" \
    && ./autogen.sh \
    && ./configure --with-incompatible-bdb --enable-hardening \
       --disable-wallet --without-gui --without-miniupnpc \
        --build=x86_64-linux-gnu \
        --prefix=${prefix} \
        --includedir=${prefix}/include --mandir=${prefix}/share/man --infodir=${prefix}/share/info --sysconfdir=/etc \
    && make \
    && make install \
    && mkdir -p /var/lib/bitcoind /var/run/bitcoind /etc/bitcoin \
    && cp /tmp/bitcoin/contrib/init/bitcoind.conf /etc/bitcoin/bitcoin.conf \
    && rm -fr /tmp/bitcoin


FROM build-bitcoin as deploy

# copy entry point script into container image (moved this to end of build in case of changes - so it's the last and only thing needed to rebuild).
COPY scripts/start.sh /sbin/start.sh
RUN chmod a+x /sbin/start.sh

# start script and hack to keep the container from exiting
ENTRYPOINT ["/sbin/start.sh"]

EXPOSE 8332/tcp
EXPOSE 8333/tcp
