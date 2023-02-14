FROM debian:stable-slim

ARG REPO_URL
ARG VERSION

ENV CHINETD_URL=${REPO_URL}/releases/download/${VERSION}/chinet-${VERSION}-cli-linux.tar.gz
ENV APP_USER=chinetd
ENV APP_UID=51291
ENV APP_DIR=/app

# P2P
EXPOSE 11121
# RPC
EXPOSE 11211
# STRATUM
EXPOSE 11777

WORKDIR $APP_DIR

ENV PATH=$APP_DIR:$PATH

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    dumb-init \
    expect \
    procps \
    iputils-ping \
    less \
    vim \
    wget \
    ca-certificates && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p $APP_DIR/.Chinet && \
  groupadd -r -g $APP_UID $APP_USER && \
  useradd -d $APP_DIR -r -m -s /sbin/nologin -g $APP_USER -u $APP_UID $APP_USER && \
  chown $APP_USER:$APP_USER $APP_DIR/.Chinet

RUN cd /tmp && \
  wget ${CHINETD_URL} 2>&1 && \
  tar xvfz chinet-${VERSION}-cli-linux.tar.gz --strip-components=1 && \
  cp chinetd $APP_DIR/ && \
  rm *

USER $APP_USER

ENTRYPOINT ["dumb-init", "--"]

CMD unbuffer /app/chinetd --stratum --stratum-miner-address=$WALLET_ADDRESS --rpc-bind-ip=0.0.0.0

