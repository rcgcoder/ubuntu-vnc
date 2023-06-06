FROM ubuntu:latest
EXPOSE 22 4444 4442 4443 5556 5557 5559 5900 5901 5902 5903 9229 9230 9231 9232
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt upgrade
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "nodejs openjdk-8-jre git npm python3" 
RUN apt install -y sudo mc openssh-server screen bash supervisor apt-utils dialog tzdata openbox xterm tigervnc-standalone-server
RUN addgroup mininode
RUN adduser --inGroup mininode --shell /bin/sh mininode 
RUN echo "mininode:mininode" | chpasswd 
RUN echo "mininode    ALL=(ALL) ALL" >> /etc/sudoers 

WORKDIR "/tmp"
RUN wget https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.9.0/selenium-server-4.9.1.jar

COPY etc/waiter.sh /etc/waiter.sh
RUN chmod 777 -R /etc/waiter.sh
COPY etc/supervisord.conf /etc/supervisord_mininode.conf

COPY runcontainer_vncserver /usr/bin/runcontainer_vncserver
RUN chmod 777 -R /usr/bin/runcontainer_vncserver
COPY containervncserver-setup.sh /usr/bin/containervncserver-setup.sh
RUN chmod 777 -R /usr/bin/containervncserver-setup.sh
COPY containervncserver-launchvnc.sh /usr/bin/containervncserver-launchvnc.sh
RUN chmod 777 -R /usr/bin/containervncserver-launchvnc.sh

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord_mininode.conf"]
