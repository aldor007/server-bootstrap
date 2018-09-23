HOST=$1
VPN_SERVER=$2
SSH_PORT=$3
USER=$4

apt-get install openvpn -y

scp -P ${SSH_PORT} ${USER}@${VPN_SERVER}://etc/openvpn/easy-rsa/keys/${HOST}* /etc/openvpn/
scp -P ${SSH_PORT} ${USER}@${VPN_SERVER}://etc/openvpn/easy-rsa/keys/ca.crt  /etc/openvpn/
rm -rf /etc/openvpn/client.conf
cat <<EOF > /etc/openvpn/client.conf
client
dev tun0
proto udp
remote ${VPN_SERVER} 1194
nobind
ca /etc/openvpn/ca.crt
cert /etc/openvpn/${HOST}.crt
key /etc/openvpn/${HOST}.key

keepalive 10 120
compress lzo
persist-key
persist-tun
verb 3
EOF

service openvpn start
echo ${HOST} > /etc/hostname
echo "127.0.0.1 ${HOST}" >> /etc/hosts  
echo "::1 ${HOST}" >> /etc/hosts  


echo "Do you are bootstraping minion? (yes or no)"
read saltType

if [[ "$saltType" -eq "yes" ]]; then
    bash ./minions.sh
else 
    bash ./master.sh
fi

echo ${HOST} > /etc/salt/minion_id
echo "Type machine segment"
read segment

echo "Type machine zone"
read zone

echo "Type machine roles (space separated)"
read roles

rm -rf /etc/salt/grains
cat <<EOF > /etc/salt/grains
segment: ${segment}
zone: ${zone}
roles: 
EOF

for role in ${roles}; do
    echo "  - ${role}" >> /etc/salt/grains
done

echo "salt-master address"
read master
echo "master: ${master}" > /etc/salt/minion
service salt-minion restart
salt-call state.highstate 

