# Multistage builds to reduce image size to ~37MB # by tuanhtrng
FROM alpine:latest as builder
WORKDIR /tmp
# Install dependencies
RUN apk add --no-cache \
    build-base \
    ctags \
    git \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    make \
    ncurses-dev \
    python \
    python-dev \
    automake \
    autoconf \
    libevent-dev
# Build vim from git source

RUN git clone https://github.com/vim/vim \
 && cd vim \
 && ./configure \
    --disable-gui \
    --disable-netbeans \
    --enable-multibyte \
    --enable-pythoninterp \
    --with-features=big \
    --with-python-config-dir=/usr/lib/python2.7/config \
 && make install

RUN wget --quiet https://github.com/tmux/tmux/archive/2.6.tar.gz -O - | tar xz \
 && cd tmux-2.6 \
 && ./autogen.sh \
 && ./configure \
 && make \
 && make install

FROM alpine:latest
COPY --from=builder /usr/local/ /usr/local/

RUN apk add --no-cache \
    libevent \
    libice \
    libsm \
    libx11 \
    libxt \
    ncurses

COPY xterm-256color-italic.terminfo /root
RUN tic /root/xterm-256color-italic.terminfo
ENV TERM=xterm-256color-italic

#ENTRYPOINT ["vim"]
