FROM debian:jessie
MAINTAINER Pat Brisbin <pat@codeclimate.com>

WORKDIR /home/app

RUN apt-get update \
  && apt-get install -y ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# We must set a region for the API client to intialize, but what region we set
# does not matter since we only access IAM, which is a cross-region service.
ENV AWS_REGION us-east-1

COPY build/popeye /home/app/popeye
COPY LICENSE /home/app/LICENSE

ENTRYPOINT ["/home/app/popeye"]
