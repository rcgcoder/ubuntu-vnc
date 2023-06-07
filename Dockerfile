FROM ubuntu:latest
EXPOSE 22 4444 4442 4443 5556 5557 5559 5900 5901 5902 5903 9229 9230 9231 9232
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt upgrade
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "nodejs openjdk-8-jre git npm python3" 
RUN apt install -y sudo mc openssh-server screen bash supervisor apt-utils dialog tzdata openbox xterm tigervnc-standalone-server gnupg wget 
RUN echo "now installing google chrome"
WORKDIR "/tmp"

RUN wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update
RUN apt-get install google-chrome-stable -y --no-install-recommends

RUN wget https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.9.0/selenium-server-4.9.1.jar

COPY etc/waiter.sh /etc/waiter.sh
RUN chmod 777 -R /etc/waiter.sh
COPY etc/supervisord.conf /etc/supervisord_mininode.conf

COPY addUserWithPassword /usr/bin/addUserWithPassword
RUN chmod 777 -R /usr/bin/addUserWithPassword
COPY runcontainer_vncserver /usr/bin/runcontainer_vncserver
RUN chmod 777 -R /usr/bin/runcontainer_vncserver
COPY containervncserver-setup.sh /usr/bin/containervncserver-setup.sh
RUN chmod 777 -R /usr/bin/containervncserver-setup.sh
COPY containervncserver-launchvnc.sh /usr/bin/containervncserver-launchvnc.sh
RUN chmod 777 -R /usr/bin/containervncserver-launchvnc.sh

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord_mininode.conf"]
