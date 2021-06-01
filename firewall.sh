#!/bin/bash

MY_NETWORK="192.168.2.0/24"
 
MY_HOST="192.168.2.20" 

# Network interfaces
IN=enp0s3
OUT=enp0s3

# Path to iptables, "/sbin/iptables"
IPTABLES="/sbin/iptables"

#=======================================

# Flushing all chains and setting default policy
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -F

$IPTABLES -L LOG_DROP &>/dev/null
if [ $? -eq 0 ]; then
    $IPTABLES -X LOG_DROP
fi

$IPTABLES -N LOG_DROP
$IPTABLES -A LOG_DROP -j LOG --log-prefix "iptables-dropped: " --log-level debug
$IPTABLES -A LOG_DROP -j DROP

##################
### START HERE ###
#################

# 1: Set the default policies 
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP 

# 2. Drop spoofed packets
$IPTABLES -A INPUT -s 10.0.0.0/8 -j LOG_DROP
$IPTABLES -A INPUT -s 172.16.0.0/12 -j LOG_DROP
$IPTABLES -A INPUT -s 169.254.0.0/16 -j LOG_DROP
$IPTABLES -A OUTPUT -s 10.0.0.0/8 -j LOG_DROP   
$IPTABLES -A OUTPUT -s 172.16.0.0/12 -j LOG_DROP
$IPTABLES -A OUTPUT -s 169.254.0.0/16 -j LOG_DROP

# 3. Allow ping and add protection from ping-flooding
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -j DROP

# 4. Allow established connections (stateful inspection)
# Let all packets belonging to an established connection, or in some way related to one, be accepted.
$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 5. Allow all traffic from the loopback device: lo (to/from)
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT

# 6. Allow outgoing traffic from your host
$IPTABLES -A OUTPUT -o $OUT -j ACCEPT

# 7. Block fragmented packets
$IPTABLES -A INPUT -f -j DROP

# 8. Drop Xmas packets
$IPTABLES -A INPUT -p tcp --tcp-flags FIN,URG,PSH FIN,URG,PSH -j DROP
$IPTABLES -A FORWARD -p tcp --tcp-flags FIN,URG,PSH FIN,URG,PSH -j DROP

# 9. Drop Null packets
$IPTABLES -A INPUT -p tcp --tcp-flags ALL None -j DROP
$IPTABLES -A FORWARD -p tcp --tcp-flags ALL None -j DROP

 
# 10. Allow specific applications
$IPTABLES -A INPUT -p tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -p udp --dport 22 -j ACCEPT

$IPTABLES -A INPUT -p tcp --dport 8080 -j ACCEPT
$IPTABLES -A INPUT -p udp --dport 8080 -j ACCEPT

$IPTABLES -A INPUT -p tcp --dport 111 -j ACCEPT
$IPTABLES -A INPUT -p udp --dport 111 -j ACCEPT


# 11. Log all other packets
$IPTABLES -A INPUT -j LOG
$IPTABLES -A FORWARD -j LOG
$IPTABLES -A OUTPUT -j LOG


echo "Done!"




