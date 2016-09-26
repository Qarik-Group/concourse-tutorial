FROM ubuntu:15.10


RUN apt-get install curl -y && \
    apt-get clean
RUN curl -L -O 'https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64.zip' \
 && unzip spiff_linux_amd64.zip \
 && mv spiff /usr/local/bin/spiff \
 && chmod u+x /usr/local/bin/spiff \
 && rm -f spiff_linux_amd64.zip

ADD spiff-merge-and-save /bin/spiff-merge-and-save
ADD git-add-all /bin/git-add-all
