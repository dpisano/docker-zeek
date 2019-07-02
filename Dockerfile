FROM alpine:3.8

RUN apk add --no-cache zlib openssl libstdc++ libpcap libgcc
RUN apk add --no-cache -t .build-deps \
  libmaxminddb-dev \
  linux-headers \
  openssl-dev \
  libpcap-dev \
  python-dev \
  zlib-dev \
  binutils \
  fts-dev \
  cmake \
  clang \
  bison \
  bash \
  swig \
  perl \
  make \
  flex \
  git \
  g++ \
  fts && \
cd /tmp && \
git clone --recursive https://github.com/zeek/zeek.git && \
cd /tmp/zeek && \
CC=clang ./configure --prefix=/usr/local/bro \
  --build-type=MinSizeRel \
  --disable-broker-tests \
  --disable-zeekctl \
  --disable-auxtools \
--disable-python && \
make -j 2 && \
make install
RUN cd /tmp/zeek/aux/ && \
git clone https://github.com/J-Gras/bro-af_packet-plugin.git && \
cd /tmp/zeek/aux/bro-af_packet-plugin && \
find . -name "*.bro" -exec sh -c 'mv "$1" "${1%.bro}.zeek"' _ {} \; && \
CC=clang ./configure --with-kernel=/usr --bro-dist=/tmp/zeek && \
make -j 2 && \
make install && \
/usr/local/bro/bin/bro -NN Bro::AF_Packet && \
cd ~/ && \
strip -s /usr/local/bro/bin/bro && \
rm -rf /var/cache/apk/* && \
rm -rf /tmp/* && \
apk del --purge .build-deps