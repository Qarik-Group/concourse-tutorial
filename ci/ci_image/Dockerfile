FROM ubuntu:15.10

RUN apt-get update && apt-get install git zip unzip curl wget vagrant file -y && \
    apt-get clean

# RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
#    \curl -sSL https://get.rvm.io | bash -s stable
# ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# RUN /bin/bash -l -c "rvm install 2.2"
# RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
# RUN /bin/bash -l -c "rvm use 2.2 --default"

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
