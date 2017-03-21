# ssr-with-net-speeder

FROM ubuntu:16.04
MAINTAINER gicoer <gicoer@gmail.com>

RUN apt-get update && \
apt-get clean  && \
apt-get install -y python python-pip python-m2crypto libnet1-dev libpcap0.8-dev git gcc openssh-server && \
apt-get clean

#ssh
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# RUN /usr/sbin/sshd -D
# RUN service ssh start
EXPOSE 22

RUN git clone -b manyuser https://github.com/shadowsocksr/shadowsocksr.git ssr
RUN git clone https://github.com/snooda/net-speeder.git net-speeder
WORKDIR net-speeder
RUN sh build.sh

RUN mv net_speeder /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/net_speeder

# Start Net Speeder
#CMD ["nohup /usr/local/bin/net_speeder venet0 \"ip\" >/dev/null 2>&1 &"]

#Test 
#CMD ["ping www.baidu.com -c 5"]


# Configure container to run as an executable
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
