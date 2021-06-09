sudo apt install apache2 #in case we want an HTTP probe
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
#the rp_filter below can be avoided if we add routes to the proper Spokes IP Ranges to the proper NIC (i.e. prod spokes to the INT device, mrz spoke to MRZ device)
echo "net.ipv4.conf.default.rp_filter = 0" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 0" | sudo tee -a /etc/sysctl.conf
for i in /proc/sys/net/ipv4/conf/*/rp_filter ; do echo 0 | sudo tee -a $i ;  done

sudo sysctl -p
# READ THIS !! https://github.com/erjosito/azure-networking-lab/blob/master/README.bak.md - step 6 sudo vi /etc/iproute2/rt_tables
#and add 201 mrz and 202 int
echo "201 mrz" | sudo tee -a /etc/iproute2/rt_tables
echo "202 int" | sudo tee -a /etc/iproute2/rt_tables
sudo ip rule add from 10.18.0.37 to 168.63.129.16 lookup mrz
sudo ip rule add from 10.18.0.101 to 168.63.129.16 lookup int

#WARNING this is not permanent!! also watch out for the ETHX number
sudo ip route add 168.63.129.16 via 10.18.0.33 dev eth2 table mrz
sudo ip route add 168.63.129.16 via 10.18.0.97 dev eth1 table int

#the routes below aren't enough, as it duplicates a route but the default GW takes precedence
#that's why you need multiple rt_tables
sudo route add 168.63.129.16 gw 10.18.0.33 metric 100
sudo route add 168.63.129.16 gw 10.18.0.97 metric 100

#now a general route to MRZ
route add -net 10.18.4.0/22 gw 10.18.0.97 dev eth1 
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 8080 -j DNAT --to 10.18.4.132:80
sudo iptables -A FORWARD -p tcp -d 10.18.4.132 --dport 80 -j ACCEPT

sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
sudo iptables-save | sudo tee -a /etc/iptables/rules.v4

#more tips in https://medium.com/contino-engineering/azure-egress-nat-with-linux-vm-595f6abd2f77