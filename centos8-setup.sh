echo "#"

# ShadowsocksR Official site
# https://github.com/shadowsocksrr

yum update
yum install shadowsocks-libev

echo "Install shadowsocks-libev finished"

while true
do
echo "Please enter a port for shadowsocks-libev"
read shadowsocksport
expr ${shadowsocksport} + 1 &>/dev/null
if [ $? -eq 0 ]; then
    if [ ${shadowsocksport} -ge 1 ] && [ ${shadowsocksport} -le 65535 ] && [ ${shadowsocksport:0:1} != 0 ]; then
        echo Enter port Success
        break
    fi
fi
echo -e "Please enter a correct port number [1-65535]"
done

echo "Please enter password for shadowsocks-libev"
read shadowsockspassword

shadowsocks_libev_config="/etc/shadowsocks-libev/config.json"
shadowsocks_libev_service="etc/systemd/system/shadowsocks-libev.service"

cat > $(shadowsocks_libev_config) <<-EOF
{
    "server":"0.0.0.0",
    "server_port":"${shadowsocksport}",
    “password":"${shadowsockspassword}",
    "timeout":600,
    "method":"chacha20",
    "fast_open":false
}
EOF

cat > $(shadowsocks_libev_service) <<-EOF
[Unit]
Description=shadowsocks-libev server
After=network.target

[Service]
TimeoutStartSec=0
Type=simple
ExecStart=/usr/local/bin/ss-server -c /etc/shadowsocks-libev/config.json
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

systemctl start shadwosocks_libev
systemctl enable shadwosocks_libev

default_zone=$(firewall-cmd --get-default-zone)
firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport}/tcp
firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport}/udp
firewall-cmd --reload
