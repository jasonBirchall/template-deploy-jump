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

#COPY /build/id_rsa /root/.ssh/id_rsa
#RUN chmod -R o-rwx /root/.ssh
WORKDIR /deploy

ENTRYPOINT eval "$(ssh-agent)" && ssh-add && grep -A1 'docker_envs' pillar/$ENV/*secrets.sls && echo "\nfab user:$USER aws:$AWS config:./cloudformation/$APP.yaml passwords:./cloudformation/$APP-secrets.yaml environment:$ENV application:$APP update\n" && /bin/bash


#ENTRYPOINT eval "$(ssh-agent)" && ssh-add && grep -A1 'docker_envs' pillar/prod/secrets.sls && echo "\nfab user:razvan-moj aws:$AWS config:./cloudformation/$APP.yaml passwords:./cloudformation/$APP-secrets.yaml environment:prod application:$APP update\n" && /bin/bash

# fab application:correspondence-staff aws:mojdsd environment:prod config:./cloudformation/correspondence-staff.yaml passwords:./cloudformation/correspondence-staff-secrets.yaml    -i ../config/default.pem  highstate -u pwyborn
# docker run -ti -v ~/.aws:/root/.aws -v $PWD:/deploy -e AWS=cla -e APP=cla-frontend USER=jasonBirchall ENV=prod templatedeploy
# docker run -it -v ~/.kube:/root/.kube -v $PWD:/data -v ~/.aws:/root/.aws -w /data -e AWS_PROFILE=moj-pi moj-tools/local /bin/bash



#FROM python:2
#
#RUN apt-get update && apt-get -y upgrade
#RUN apt-get -y install python-pip build-essential cmake libssh-dev libssh2-1-dev
#RUN pip install --upgrade pip
#
#COPY ./build /build
#WORKDIR /build/libgit2-0.27.3
#RUN cmake . && make && make install && ldconfig
#WORKDIR /build
## RUN pip install -r formula-requirements.txt
#RUN pip install -r requirements.txt
#
#COPY razvanmoj.key /root/.ssh/id_rsa
#RUN chmod -R o-rwx /root/.ssh
#COPY config credentials /root/.aws/
#WORKDIR /deploy
#
#ENTRYPOINT eval "$(ssh-agent)" && ssh-add && grep -A1 'docker_envs' pillar/prod/secrets.sls && echo "\nfab user:razvan-moj aws:$AWS config:./cloudformation/$APP.yaml passwords:./cloudformation/$APP-secrets.yaml environment:prod application:$APP update\n" && /bin/bash
