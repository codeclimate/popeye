FROM haskell:7.10
MAINTAINER Pat Bribin <pat@codeclimate.com>

WORKDIR /home/app

RUN apt-get update \
  && apt-get install -y curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Fix dependencies to LTS 4.2
RUN curl -o /home/app/cabal.config https://www.stackage.org/lts-4.2/cabal.config

# Pre-install large dependencies in separate layer
RUN cabal update && cabal install \
  amazonka \
  amazonka-iam \
  lens

COPY popeye.cabal /home/app/popeye.cabal
RUN cabal install --dependencies-only

COPY LICENSE /home/app/LICENSE
COPY src /home/app/src
COPY app /home/app/app
RUN cabal build

ENTRYPOINT ["/home/app/dist/build/popeye/popeye"]
