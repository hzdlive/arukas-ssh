# ssr-with-net-speeder

FROM ubuntu:16.04

RUN apt-get update && \
apt-get clean  && \
apt-get install -y pwgen wget python python-pip python-m2crypto libnet1-dev libpcap0.8-dev git gcc openssh-server && \
apt-get clean

#ssh
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN /usr/sbin/sshd -D
EXPOSE 22

#install libsodium support chacha20
RUN wget --no-check-certificate -O libsodium-1.0.11.tar.gz https://github.com/jedisct1/libsodium/releases/download/1.0.11/libsodium-1.0.11.tar.gz &&\
    tar zxf libsodium-1.0.11.tar.gz && rm -rf libsodium-1.0.11.tar.gz
WORKDIR libsodium-1.0.11
RUN ./configure && make && make install
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf
RUN ldconfig && cd .. && rm -rf libsodium-1.0.11

RUN git clone -b manyuser https://github.com/breakwa11/shadowsocks.git ssr
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
