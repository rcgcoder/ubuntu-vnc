FROM ubuntu:latest
MAINTAINER rcgcoder
EXPOSE 22 4444 4442 4443 5556 5557 5559 5900 5901 5902 5903 9229 9230 9231 9232
RUN apt upgrade
RUN apt update

RUN apt install sudo mc openssh-server screen bash nodejs openjdk8 git npm python3 
RUN addgroup mininode
RUN adduser  -G mininode -s /bin/sh -D mininode 
RUN echo "mininode:mininode" | /usr/sbin/chpasswd 
RUN echo "mininode    ALL=(ALL) ALL" >> /etc/sudoers 
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
RUN /usr/sbin/sshd
WORKDIR "/tmp"
RUN wget https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.9.0/selenium-server-4.9.1.jar

COPY etc/waiter.sh /etc/waiter.sh
RUN chmod 777 -R /etc/waiter.sh
ENTRYPOINT ["/bin/bash", "-c", "/etc/waiter.sh"]
