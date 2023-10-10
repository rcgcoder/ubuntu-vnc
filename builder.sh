#!/bin/bash
docker build --no-cache --force-rm --platform linux/amd64 https://github.com/rcgcoder/ubuntu-vnc.git -t rcgcoder/ubuntu-vnc:amd64
docker push rcgcoder/ubuntu-vnc:amd64;
sleep 10;
docker manifest rm rcgcoder/ubuntu-vnc:manifest-latest;
docker manifest create rcgcoder/ubuntu-vnc:manifest-latest
	 --amend rcgcoder/ubuntu-vnc:latest 
	 --amend rcgcoder/ubuntu-vnc:amd64

docker manifest push rcgcoder/ubuntu-vnc:manifest-latest
docker manifest push rcgcoder/ubuntu-vnc:latest
docker manifest push rcgcoder/ubuntu-vnc:amd64

