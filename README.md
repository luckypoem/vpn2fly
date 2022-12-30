# vpn2fly

vpn(wireguard) over v2ray over websocket-secure

* vpn for client global proxy
* v2ray for obscured vpn, made it hard to detect by GFW
* websocket-secure for security, made it more hard to detect by GFW

## why vpn2fly

* cert are automatically generated and updated
* deployed in one run and can keep alive even after reboot (tested on azure vm)

## prerequest

* a vps located abroad
* docker compose, user should be in the docker group
* python3, git
* brew (for macos client)

## server side

### server init

1. `git clone git@github.com:dusmart/vpn2fly.git && cd vpn2fly`
2. change `${YOUR-V2RAY-UUID}` to some uuid generated by `uuidgen`
3. change `${YOUR-VPS-DOMAIN}` to your vps's domain

### use

* `cd vpn2fly && docker compose up -d` to start and run at computer start up
* `cd vpn2fly && docker compose down` to stop and remove it at computer start up

## cient side (macos)

### client init

1. `brew install v2ray`
2. `cp client.json /opt/homebrew/etc/v2ray/config.json`
3. `brew services start v2ray` to start and run at computer start up
4. `brew service stop v2ray` to stop and remove it at computer start up
5. install the free [wireguard](https://apps.apple.com/us/app/wireguard) in app store
6. add a config showed in `vpn2fly/wireguard/peer1/peer1.conf` on server
7. change the ListenPort in section \[Interface\] to `51821`
8. change the DNS in section \[Interface\] to `8.8.8.8`
9. put the ip of your server to `ipcal.py`'s exclude array
10. change the AllowedIPs in section \[Peer\] to `python ipcal.py`

### only use the socks5 and http proxy

* find the proxy in your system proxy (search `proxy` in system settings)
* set http and https proxy to 127.0.0.1:8002
* set socks5 proxy to 127.0.0.1:1082

### use vpn over v2ray

* open/close the switch in wireguard or system settings
