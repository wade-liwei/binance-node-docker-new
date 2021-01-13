FROM ubuntu:20.04

ENV BNBD_HOME=/bnbd


# Install ca-certificates
RUN apt-get update
RUN apt-get install wget  -y
RUN apt-get install supervisor -y


# UPDATE ME when new version is out !!!!
ARG CLI_LATEST_VERSION="0.8.0-hotfix"
ARG FULLNODE_LATEST_VERSION="0.8.0"
ARG GH_REPO_URL="https://github.com/binance-chain/node-binary/raw/master"
ARG FULLNODE_VERSION_PATH="fullnode/prod/${FULLNODE_LATEST_VERSION}"

RUN mkdir -p /tmp/bin

WORKDIR /tmp/bin

RUN set -ex \
&& cd  /tmp/bin \
&& FULLNODE_BINARY_URL="$GH_REPO_URL/$FULLNODE_VERSION_PATH/linux/bnbchaind" \
&& wget  -q  "$FULLNODE_BINARY_URL"


RUN install -m 0777 -o root -g root -t /usr/local/bin bnbchaind
RUN chmod +x /usr/local/bin/bnbchaind


RUN set -ex \
&& mkdir -p /tmp/config  \
&& cd /tmp/config \
&& FULLNODE_CONFIG_URL="$GH_REPO_URL/$FULLNODE_VERSION_PATH/config"  \
&& wget  -q   "$FULLNODE_CONFIG_URL/app.toml"  \
&& wget  -q   "$FULLNODE_CONFIG_URL/config.toml"  \
&& wget  -q   "$FULLNODE_CONFIG_URL/genesis.json"  \
&& sed   -i   's/logToConsole = false/logToConsole = true/g'   app.toml


# Add supervisor configuration files
RUN mkdir -p /etc/supervisor/conf.d/
COPY /supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY /supervisor/conf.d/* /etc/supervisor/conf.d/


WORKDIR $BNBD_HOME


# Expose ports for bnbd
EXPOSE 27146 27147 26660

# Add entrypoint script
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

STOPSIGNAL SIGINT
