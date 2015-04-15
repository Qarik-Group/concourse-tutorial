FROM concourse/buildbox-ci

RUN cd /tmp && \
    curl -L -o spiff_linux_amd64.zip https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.5/spiff_linux_amd64.zip && \
    unzip spiff_linux_amd64.zip && \
    mv spiff /bin/

RUN apt-get -y update

# install ruby
RUN apt-get install -y ruby ruby-dev ruby-bundler

# bundler
RUN apt-get install -y postgresql-server-dev-9.3
RUN apt-get install -y libsqlite3-dev
RUN apt-get install -y libmysqlclient-dev
RUN gem install bundler

RUN apt-get install -y wget curl unzip
