FROM ubuntu:latest
EXPOSE 22 4444 4442 4443 5556 5557 5559 5900 5901 5902 5903 9229 9230 9231 9232
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt upgrade
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "nodejs openjdk-8-jre git npm python3" 
RUN apt install -y sudo mc openssh-server screen bash supervisor apt-utils dialog tzdata openbox xterm tigervnc-standalone-server gnupg wget 

WORKDIR "/tmp"

RUN echo "now installing google chrome"
RUN wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update
RUN apt-get install google-chrome-stable -y --no-install-recommends

RUN echo "now openjdk"
RUN apt install -y openjdk-8-jre curl 

RUN echo "selenium server for make a grid if we want"
RUN wget https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.9.0/selenium-server-4.9.1.jar

RUN echo "NODEJS 14"
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
RUN apt-get update
RUN apt -y install nodejs 
RUN apt -y install gcc g++ make 
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update
RUN apt install yarn

RUN echo "NODEJS 16"
RUN curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
RUN apt-get update
RUN apt-get -y upgrade
RUN apt -y install nodejs
RUN npm install -g npm@*  

RUN apt-get install -y zenity xdotool libaio1 expect chromium-chromedriver
RUN npm install -g chromedriver  


RUN mkdir -p /usr/src/app
COPY nodejsExpressHelloWorld.js /usr/src/app/main.js
RUN chmod 777 -R /usr/src/app/main.js

WORKDIR "/usr/src/app"
RUN npm install express

COPY etc/waiter.sh /etc/waiter.sh
RUN chmod 777 -R /etc/waiter.sh
COPY etc/supervisord.conf /etc/supervisord.conf

COPY addUserWithPassword /usr/bin/addUserWithPassword
RUN chmod 777 -R /usr/bin/addUserWithPassword
COPY runcontainer_vncserver /usr/bin/runcontainer_vncserver
RUN chmod 777 -R /usr/bin/runcontainer_vncserver
COPY containervncserver-setup.sh /usr/bin/containervncserver-setup.sh
RUN chmod 777 -R /usr/bin/containervncserver-setup.sh
COPY containervncserver-launchvnc.sh /usr/bin/containervncserver-launchvnc.sh
RUN chmod 777 -R /usr/bin/containervncserver-launchvnc.sh

COPY runcontainer_vncnodejs /usr/bin/runcontainer_vncnodejs
RUN chmod 777 -R /usr/bin/runcontainer_vncnodejs
COPY containervncnodejs-setup.sh /usr/bin/containervncnodejs-setup.sh
RUN chmod 777 -R /usr/bin/containervncnodejs-setup.sh

ENTRYPOINT ["/bin/bash", "-c", "/usr/bin/runcontainer_vncnodejs"]
