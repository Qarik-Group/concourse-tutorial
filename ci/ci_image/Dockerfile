FROM ubuntu:16.10

RUN apt-get update && \
  apt-get install -y git zip unzip curl wget zlib1g-dev libxml2 dirmngr && \
  apt-get clean && \
  gpg --keyserver hkp://keys.gnupg.net \
  --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
  \curl -sSL https://get.rvm.io | bash -s stable

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY gemrc /root/.gemrc
RUN /bin/bash -l -c "rvm install 2.2.4 && \
  rvm use 2.2.4 --default && \
  rvm 2.2.4 do gem install bosh_cli colorize"

ADD https://github.com/concourse/concourse/releases/download/v2.6.0/fly_linux_amd64 /usr/local/bin/fly
RUN chmod 755 /usr/local/bin/fly
