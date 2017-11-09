# vim: ft=dockerfile
FROM haskell:8
MAINTAINER Pat Brisbin <pat@codeclimate.com>

WORKDIR /home/app

RUN apt-get update \
  && apt-get install -y curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Fix dependencies to LTS 9.12
RUN curl -o /home/app/cabal.config https://www.stackage.org/lts-9.12/cabal.config

# Pre-install large dependencies in separate layer
RUN cabal update && cabal install \
  amazonka \
  amazonka-iam \
  hpack \
  lens \
  optparse-applicative

COPY package.yaml /home/app/package.yaml

RUN hpack
RUN cabal install --dependencies-only

COPY LICENSE /home/app/LICENSE
COPY src /home/app/src
COPY app /home/app/app
# Run hpack again now that src/app are present, so it can correctly create the
# modules declaration.
RUN hpack
RUN cabal configure -fstatic
RUN cabal build
