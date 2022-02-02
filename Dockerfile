#  creates a layer from the base Docker image.
FROM debian:stable-slim

WORKDIR /app

# https://shouldiblamecaching.com/
ENV PIP_NO_CACHE_DIR 1

# http://bugs.python.org/issue19846
# https://github.com/SpEcHiDe/PublicLeech/pull/97
ENV LANG C.UTF-8

# we don't have an interactive xTerm
ENV DEBIAN_FRONTEND noninteractive

# sets the TimeZone, to be used inside the container
ENV TZ Asia/Kolkata

# to resynchronize the package index files from their sources.
RUN apt -qq update

RUN apt -qq install -y --no-install-recommends \
    # this package is required to fetch "contents" via "TLS"
    apt-transport-https \
    build-essential \
    coreutils bash \
    curl git \
    gnupg2 gcc \
    jq pv \
    wget && \
    # clean up the container "layer", after we are done
    rm -rf /var/lib/apt/lists /var/cache/apt/archives /tmp

# each instruction creates one layer
# Only the instructions RUN, COPY, ADD create layers.
# requiring the use of the entire repo, hence
# adds files from your Docker client’s current directory.
COPY telegram_bot.sh .

# specifies what command to run within the container.
CMD ["bash", "telegram_bot.sh"]
