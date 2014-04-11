FROM centos

# telnet is required by some fabric command. without it you have silent failures
RUN yum install -y java-1.7.0-openjdk which telnet unzip openssh-server sudo openssh-clients
# enable no pass and speed up authentication
RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/;s/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

# enabling sudo group
RUN echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
# enabling sudo over ssh
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers

ENV JAVA_HOME /usr/lib/jvm/jre

ENV FABRIC8_KARAF_NAME root
ENV FABRIC8_BINDADDRESS 0.0.0.0
ENV FABRIC8_PROFILES docker

# add a user for the application, with sudo permissions
RUN useradd -m fabric8 ; echo fabric8: | chpasswd ; usermod -a -G wheel fabric8

# assigning higher default ulimits
# unluckily this is not very portable. these values work only if the user running docker daemon on the host has his own limits >= than values set here
# if they are not, the risk is that the "su fuse" operation will fail
RUN echo "fabric8                -       nproc           4096" >> /etc/security/limits.conf
RUN echo "fabric8                -       nofile           4096" >> /etc/security/limits.conf

# command line goodies
RUN echo "export JAVA_HOME=/usr/lib/jvm/jre" >> /etc/profile
RUN echo "alias ll='ls -l --color=auto'" >> /etc/profile
RUN echo "alias grep='grep --color=auto'" >> /etc/profile


WORKDIR /home/fabric8

#RUN curl --silent --output fabric8.zip https://repository.jboss.org/nexus/content/groups/fs-public-snapshots/io/fabric8/runtime/fabric8-tomcat/1.1.0-SNAPSHOT/fabric8-tomcat-1.1.0-20140408.092939-5.zip
RUN curl --silent --output fabric8.zip https://repository.jboss.org/nexus/content/repositories/fs-public/io/fabric8/runtime/fabric8-tomcat/1.1.0.Beta1/fabric8-tomcat-1.1.0.Beta1.zip
RUN unzip -q fabric8.zip 
RUN ls -al
#RUN mv fabric8-tomcat-1.1.0-SNAPSHOT fabric8-tomcat
RUN mv fabric8-tomcat-1.1.0.Beta1 fabric8-tomcat
RUN rm fabric8.zip
#RUN chown -R fabric8:fabric8 fabric8-tomcat

#USER fabric8

WORKDIR /home/fabric8/fabric8-tomcat/etc

# lets remove the karaf.name by default so we can default it from env vars
#RUN sed -i '/karaf.name=root/d' system.properties 

#RUN echo bind.address=0.0.0.0 >> system.properties
#RUN echo fabric.environment=docker >> system.properties

# lets remove the karaf.delay.console=true to disable the progress bar
#RUN sed -i '/karaf.delay.console=true/d' config.properties 
#RUN echo karaf.delay.console=false >> config.properties

# lets add a user - should ideally come from env vars?
#RUN echo >> users.properties 
#RUN echo admin=admin,admin >> users.properties 

# lets enable logging to standard out
#RUN echo log4j.rootLogger=INFO, stdout, osgi:* >> org.ops4j.pax.logging.cfg 

WORKDIR /home/fabric8/fabric8-tomcat

# ensure we have a log file to tail 
#RUN mkdir -p data/log
#RUN echo >> data/log/karaf.log

WORKDIR /home/fabric8

RUN curl --silent --output startup.sh https://raw.githubusercontent.com/fabric8io/fabric8-tomcat-docker/cc23a6c56176ffaefba58c09cc1281872c38c44c/startup.sh
RUN chmod +x startup.sh

EXPOSE 22 1099 2181 8101 8080 9300 9301 44444 61616 

#USER root

CMD /home/fabric8/startup.sh
