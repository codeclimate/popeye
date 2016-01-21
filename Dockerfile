FROM debian:jessie
MAINTAINER Pat Brisbin <pat@codeclimate.com>

WORKDIR /home/app

RUN apt-get update \
  && apt-get install -y ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY build/ /home/app/
COPY LICENSE /home/app/LICENSE

ENTRYPOINT ["/home/app/popeye"]
