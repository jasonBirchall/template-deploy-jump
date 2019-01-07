# Run template-deploy env in a container¬
#¬
# example:¬
# docker run \¬
#       -ti \¬
#       -v ~/.aws:/root/.aws \¬
#       -v ~/.ssh:/root/.ssh \¬
#       -v $PWD:/deploy \¬
#       -e AWS=mojdsd \¬
#       -e APP=pvp2 \¬
#       -e ENV=staging \¬
#       -e USER=jasonBirchall \¬
#       template-deploy /bin/bash

FROM python:2

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install python-pip build-essential cmake libssh-dev libssh2-1-dev unzip
RUN pip install --upgrade pip

RUN wget https://github.com/libgit2/libgit2/archive/v0.27.3.zip && unzip v0.27.3.zip
WORKDIR /libgit2-0.27.3
RUN cmake . && make && make install && ldconfig
COPY ./build /build
WORKDIR /build
RUN pip install -r requirements.txt

WORKDIR /deploy

# register ssh key and then output the update command
ENTRYPOINT eval "$(ssh-agent)" && ssh-add && grep -A1 'docker_envs' pillar/$ENV/*secrets.sls && echo "\nfab user:$USER aws:$AWS config:./cloudformation/$APP.yaml passwords:./cloudformation/$APP-secrets.yaml environment:$ENV application:$APP update\n" && /bin/bash

