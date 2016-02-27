FROM concourse/concourse-ci
# https://github.com/concourse/concourse/blob/master/ci/dockerfiles/concourse-ci/Dockerfile

RUN apt-get update && apt-get install zip unzip curl wget vagrant file -y && \
    apt-get clean

RUN vagrant plugin install vagrant-aws

ADD https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 /usr/bin/jq
RUN chmod 775 /usr/bin/jq

# Install Go & yaml2json
RUN \
  mkdir -p /goroot && \
  curl https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1

# Set environment variables.
ENV GOROOT /goroot
ENV GOPATH /gopath
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

RUN go get github.com/bronze1man/yaml2json
