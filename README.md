# Network-Security

** Setting up firewall using iptables in Linux **

* configure

find the host / network interface
/sbin/ifconfig or /sbin/ip addr show

run the script
./firewall.sh

List current firewall configuration
sudo /sbin/iptables -nvL

=================================
* Test firewall rules

Firewall: 192.168.2.20/24
Test host: 192.168.2.40/24
Services running on Firewall vm: SSH server (22), Web server(8080), portmapper(111)

SPOOFED_IP_ADDR = "10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16" (exclude any if connected to them)

=================================

1. Set the default policies

2. Drop spoofed packets

   From Firewall vm
   namp -v -sS 192.168.2.40 -S SPOOFED_IP_ADDR -e enp0s3 -Pn -p80

   From Test host
   nmap -v -sS 192.168.2.20 -S SPOOFED_IP_ADDR -e eth0 -Pn -p80 


3. Allow ping and add protection from ping-flooding

   From Test host ping-flood Firewall
   ping -i 0.2 192.168.2.20 (5 packets/sec)

   Watch kernel log file
   watch -n 0,2 'dmesg | tail'


4. Allow established connections (stateful inspection)

  Issue ICMP echo request 
  ping 192.168.2.40 (From Firewall should be allowed)
  ping 192.168.2.20 (From Test host should be blocked)

  Perform Ack scan
  nmap -v -sA -p 1-1024 192.168.2.20


5. Allow all traffic from the loopback device: lo (to/from)
   ping localhost


6. Allow outgoing traffic from your host

   From Firewall vm to ping Test host
   ping 192.168.2.40


7. Block fragmented packets

   send fragmented packets
   nmap -v -f -p 1-1024 192.168.2.20

8. Drop Xmas packets

   Perform Xmas scan
   namp -v -sX -p 1-1024 192.168.2.20

9. Drop Null packets

   Perform Null scan
   nmap -v -sN -p 1-1024 192.168.2.20

10. Allow specific applications

    Perform SYN scan to check open ports
    nnmap -v 192.168.2.20 -sS -p22,8080,111 (should be opened)
    nmamp -v 192.168.2.40 -sS -p443 (should be filtered)

    Test Services
    curl 192.168.2.20:22 (protocol mismatched)
    curl 192.168.2.20:8080 (Get HTML text response)
    curl 192.168.2.20.111 (protocol mismatched)

    SSH to Firewall vm on port 22
    ssh 192.168.2.20:22
  



** Setting up signature-based IDS system using snort **
