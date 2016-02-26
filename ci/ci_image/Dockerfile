FROM concourse/concourse-ci
# https://github.com/concourse/concourse/blob/master/ci/dockerfiles/concourse-ci/Dockerfile

RUN apt-get update && apt-get install zip unzip curl wget bzr python-pip -y && \
    pip --no-input install awscli && \
    apt-get clean

ADD https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 /usr/bin/jq
RUN chmod 775 /usr/bin/jq

ADD https://github.com/geofffranks/spruce/releases/download/v1.0.3/spruce-linux-amd64 /usr/bin/spruce
RUN chmod 755 /usr/bin/spruce

# Install Go
RUN \
  mkdir -p /goroot && \
  curl https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1

# Set environment variables.
ENV GOROOT /goroot
ENV GOPATH /gopath
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

RUN go get github.com/bronze1man/yaml2json
RUN gem install fog mime-types --no-ri --no-rdoc
