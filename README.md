# Template Deploy Jump Image

## Table of contents

  * [Overview](#overview)
  * [Pre-requisites](#Pre-requisites)
  * [Build image](#build-image)
  * [Run image](#run-image)

## TL;DR
```
# build the image
$ docker build . -t template-deploy

# run the image
$ docker run \
       -ti \
       -v ~/.aws:/root/.aws \
       -v ~/.ssh:/root/.ssh \
       -v $PWD:/deploy \
       -e AWS=mojdsd \
       -e APP=pvb \
       -e ENV=staging \
       -e USER=jasonBirchall \
       template-deploy \
       /bin/bash
```

## Overview
For a while, WebOps engineers at the MoJ Digital have complained about the amount of time it takes to run `fabric` commands to update live environments deployed by Template Deploy. We created this image to enable a build once jump image, allowing engineers to build the image locally and then `exec` into the container and execute relevant commands. 

## Pre-requisites
It is assumed you have the following:
- Docker, git.
- Access to the *Deploy repository, including `git-crypt` access. 
- An SSH key that has been added to said *Deploy repo.
- Your ssh keys are stored in the default location `~/.ssh`
- AWS access with a valid API key. 
- Your AWS access keys are stored in the default location `~/.aws`
- A GitHub username. 

## Build image
You need to build the image locally, this will allow you to `exec` in and start running `fab` commands:
```bash
$ git clone git@github.com:jasonBirchall/template-deploy-jump.git
$ cd template-deploy-jump
$ docker build . -t template-deploy
```

The `./Dockerfile` is expecting the user to define a number of environment variables. This task is completed in the `Run Image` section of this README and allows the user to define application name, username and AWS profile. 

## Run image
Once your image is built (`docker images | grep template-deploy`), you can clone the *deploy repository you need to `fab update` and change directory, in the example below, I'll use [pvb2-deploy](https://github.com/ministryofjustice/pvb2-deploy).
```bash
$ git clone git@github.com:ministryofjustice/pvb2-deploy.git
$ cd pvb2-deploy
$ git-crypt unlock
```
Next we're going to run our `docker` image with a few arguments. Again, I'm going to use [pvb2-deploy](https://github.com/ministryofjustice/pvb2-deploy) with my own AWS profile name (`mojdsd`) and GitHub user (`jasonBirchall`) as an example.
``` bash
$ docker run \
       -ti \
       -v ~/.aws:/root/.aws \
       -v ~/.ssh:/root/.ssh \
       -v $PWD:/deploy \
       -e AWS=mojdsd \
       -e APP=pvb2 \
       -e ENV=staging \
       -e USER=jasonBirchall \
       template-deploy \
       /bin/bash
```
A prompt will appear for your ssh private key password. Once entered, you'll be on the terminal inside your image. It should look like the below:
```bash
Enter passphrase for /root/.ssh/id_rsa:
Identity added: /root/.ssh/id_rsa (/root/.ssh/id_rsa)
pillar/staging/staging-secrets.sls:docker_envs:
pillar/staging/staging-secrets.sls-  staging-pvb.dsd.io:

fab user:jasonBirchall aws:mojdsd config:./cloudformation/pvb2.yaml passwords:./cloudformation/pvb2-secrets.yaml environment:staging application:pvb2 update

root@f3f0944277bf:/deploy#
```
You can now start running `fab` commands from your terminal. For convenience, the Docker image outputs the update command for you.

`fab user:jasonBirchall aws:mojdsd config:./cloudformation/pvb2.yaml passwords:./cloudformation/pvb2-secrets.yaml environment:staging application:pvb2 update`

*Please note: the config and secrets file path may differ depending on repository* 

Execute your `fab` command and then `exit` the image when complete.
