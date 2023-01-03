set -e

if [ $# -ne 1 ]
  then
    echo "usage: bash init.sh YOUR-VPS-DOMAIN\nexample: bash init.sh vps.dusmart.example.com"
    exit 1
fi

if [ -d "v2fly-core" ]; then
    echo "== you should delete old v2fly-core first =="
    exit 1
fi
if [ -d "nginx-certbot" ]; then
    echo "== you should delete old nginx-certbot first =="
    exit 1
fi
if [ -d "wireguard" ]; then
    echo "== you should delete old wireguard first =="
    exit 1
fi
if [ -f "client.json" ]; then 
    echo "== you should delete old client.json first =="
    exit 1
fi

uuid=`uuidgen`
domain=$1
ip=`dig +short ${domain} | tail -n 1`

if ! [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "bad domain, can not get ip by running dig +short ${domain}"
    exit 1
fi

echo "== save below AllowedIPs to somewhere, you'll need it in your vpn client =="
python3 ipcal.py ${ip}

echo "== your secret id in v2ray =="
echo $uuid
echo "== creating configs =="
mkdir v2fly-core
mkdir -p nginx-certbot/user_conf.d
mkdir wireguard

echo 'upstream v2fly {
  server 10.13.128.1:1024;
}
server {
    # Listen to port 443 on both IPv4 and IPv6.
    listen 443 ssl default_server reuseport;
    listen [::]:443 ssl default_server reuseport;

    # Domain names this server should respond to.
    server_name '${domain}';

    # Load the certificate files.
    ssl_certificate         /etc/letsencrypt/live/v2fly-cloudapp/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/v2fly-cloudapp/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/v2fly-cloudapp/chain.pem;

    # Load the Diffie-Hellman parameter.
    ssl_dhparam /etc/letsencrypt/dhparams/dhparam.pem;
    ssl_protocols TLSv1.2 TLSv1.3;

    add_header Strict-Transport-Security max-age=15768000;

    location / {
        proxy_set_header HOST $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://v2fly;
    }

}' >> nginx-certbot/user_conf.d/v2fly.conf

echo '{
    "log": {
	"access": "/etc/v2ray/access.log",
	"error": "/etc/v2ray/error.log",
        "loglevel": "warning"
    },
    "inbounds": [{
            "listen": "10.13.128.1",
            "port": 1024,
            "protocol": "vmess",
            "settings": { "clients": [{ "id": "'${uuid}'" }]},
            "streamSettings": {
                "network": "ws",
                "wsSettings": { "path": "/lazy" }
            }
    }],
    "outbounds": [{ "protocol": "freedom" }]
}' >> v2fly-core/config.json

echo '{
    "routing": {
        "name": "bypasscn_private_apple",
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            {
                "type": "field",
                "inboundTag": [
                    "wginbound"
                ],
                "outboundTag": "'${domain}'"
            },
            {
                "type": "field",
                "outboundTag": "direct",
                "domain": [
                    "localhost",
                    "domain:me.com",
                    "domain:lookup-api.apple.com",
                    "domain:icloud-content.com",
                    "domain:icloud.com",
                    "domain:cdn-apple.com",
                    "domain:apple-cloudkit.com",
                    "domain:apple.com",
                    "domain:apple.co",
                    "domain:aaplimg.com",
                    "domain:guzzoni.apple.com",
                    "geosite:cn"
                ]
            },
            {
                "type": "field",
                "outboundTag": "direct",
                "ip": [
                    "geoip:private",
                    "geoip:cn"
                ]
            },
            {
                "type": "field",
                "outboundTag": "'${domain}'",
                "port": "0-65535"
            }
        ]
    },
    "inbounds": [
        {
            "listen": "127.0.0.1",
            "protocol": "socks",
            "settings": {
                "ip": "127.0.0.1",
                "auth": "noauth",
                "udp": false
            },
            "tag": "socksinbound",
            "port": 1082
        },
        {
            "listen": "127.0.0.1",
            "protocol": "http",
            "settings": {
                "timeout": 0
            },
            "tag": "httpinbound",
            "port": 8002
        },
        {
            "tag": "wginbound",
            "protocol": "dokodemo-door",
            "port": 51821,
            "listen": "127.0.0.1",
            "network": "udp",
            "settings": {
                "address": "10.13.13.1",
                "port": 51820,
                "network": "udp"
            }
        }
    ],
    "dns": {
        "servers": [
            "8.8.8.8"
        ]
    },
    "log": {
        "error": "",
        "loglevel": "info",
        "access": ""
    },
    "outbounds": [
        {
            "tag": "direct",
            "protocol": "freedom",
            "settings": {}
        },
        {
            "sendThrough": "0.0.0.0",
            "mux": {
                "enabled": false,
                "concurrency": 8
            },
            "protocol": "vmess",
            "settings": {
                "vnext": [
                    {
                        "address": "'${ip}'",
                        "users": [
                            {
                                "id": "'${uuid}'",
                                "alterId": 0,
                                "security": "none",
                                "level": 0
                            }
                        ],
                        "port": 443
                    }
                ]
            },
            "tag": "'${domain}'",
            "streamSettings": {
                "wsSettings": {
                    "path": "/lazy",
                    "headers": {}
                },
                "quicSettings": {
                    "key": "",
                    "header": {
                        "type": "none"
                    },
                    "security": "none"
                },
                "tlsSettings": {
                    "allowInsecure": false,
                    "alpn": [
                        "http/1.1"
                    ],
                    "serverName": "'${domain}'",
                    "allowInsecureCiphers": false
                },
                "httpSettings": {
                    "path": ""
                },
                "kcpSettings": {
                    "header": {
                        "type": "none"
                    },
                    "mtu": 1350,
                    "congestion": false,
                    "tti": 20,
                    "uplinkCapacity": 5,
                    "writeBufferSize": 1,
                    "readBufferSize": 1,
                    "downlinkCapacity": 20
                },
                "tcpSettings": {
                    "header": {
                        "type": "none"
                    }
                },
                "security": "tls",
                "network": "ws"
            }
        }
    ]
}' > client.json

echo "== configs complete =="
client=`echo '{"host":"'${domain}'","ps":"'${domain}'","net":"ws","add":"'${domain}'","aid":"0","id":"'${uuid}'","port":443,"path":"\/lazy","tls":"tls","type":"none"}' | base64`
client=`echo $client | tr -d " "`
client='vmess://'$client
echo "== import this link to your mobile app or scan the qrcode below =="
echo $client
echo $client | qrencode -t ansiutf8
