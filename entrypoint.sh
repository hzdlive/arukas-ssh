#!/bin/bash
# nohup /usr/sbin/sshd -D &
/usr/sbin/sshd -D &
nohup /usr/local/bin/net_speeder eth0 "ip" >/dev/null 2>&1 &
ping www.baidu.com -c 5


/usr/bin/python /ssr/shadowsocks/server.py "$@"
