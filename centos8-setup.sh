echo "#"

# ShadowsocksR Official site
# https://github.com/shadowsocks/shadowsocks-rust

# Download new official package
# Check the new version from https://github.com/shadowsocks/shadowsocks-rust/releases
# Update the new version link
echo "Download package"
curl -LJo shadowsocks-rust-gnu.tar.xz https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.10.1/shadowsocks-v1.10.1.x86_64-unknown-linux-gnu.tar.xz
# must use J to unarchive
tar -xJf shadowsocks-rust-gnu.tar.xz -C /usr/local/bin
rm -f shadowsocks-rust-gnu.tar.xz

echo "Install shadowsocks-rust finished"

echo "Enter port and password"
while true
do
echo "Please enter a port for shadowsocks"
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

echo "Please enter password for shadowsocks"
read shadowsockspassword

echo "Enter second port and password"
while true
do
echo "Please enter a port for shadowsocks"
read shadowsocksport1
expr ${shadowsocksport} + 1 &>/dev/null
if [ $? -eq 0 ]; then
    if [ ${shadowsocksport} -ge 1 ] && [ ${shadowsocksport} -le 65535 ] && [ ${shadowsocksport:0:1} != 0 ]; then
        echo Enter port Success
        break
    fi
fi
echo -e "Please enter a correct port number [1-65535]"
done

echo "Please enter password for shadowsocks"
read shadowsockspassword1

# Make config file
shadowsocks_config="/etc/shadowsocks/config.json"
shadowsocks_service="/etc/systemd/system/shadowsocks.service"

if [ ! -d "$(dirname ${shadowsocks_config})" ]; then
    mkdir -p $(dirname ${shadowsocks_config})
fi

cat > ${shadowsocks_config} <<-EOF
{
    "servers": [
        {
            "address":"0.0.0.0",
            "port":${shadowsocksport},
            "password":"${shadowsockspassword}",
            "timeout":7200,
            "method":"aes-256-gcm"
        },
        {
            "address":"0.0.0.0",
            "port":${shadowsocksport1},
            "password":"${shadowsockspassword1}",
            "timeout":7200,
            "method":"chacha20-ietf-poly1305"
        }
    ]
}
EOF

cat > ${shadowsocks_service} <<-EOF
[Unit]
Description=shadowsocks server
After=network.target

[Service]
TimeoutStartSec=0
Type=simple
ExecStart=/usr/local/bin/ssserver -c ${shadowsocks_config}
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# start service
systemctl daemon-reload
systemctl start shadowsocks
systemctl enable shadowsocks

default_zone=$(firewall-cmd --get-default-zone)
firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport}/tcp
firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport}/udp
firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport1}/tcp
firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport1}/udp
firewall-cmd --reload
