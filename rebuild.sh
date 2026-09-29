#!/bin/bash

docker rm -f keystone
docker rmi my-keystone
docker build -t my-keystone .
