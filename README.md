[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<div align="center">
  <h3 align="center">ONE-SHOT-SOLUTION-VPN-OVER-V2RAY</h3>

  <p align="center">
    vpn over v2ray disguised by wss, vpn is optional
  </p>
</div>

## Why vpn2fly

* **minimal steps**
  * **one shot** init: only *domain* is the necessary parameter
  * **one shot** deploy: they're all handled by docker dompose
  * **one shot** connect: qrcode / vmess-url / configs generated for client, no mannual config is needed
  * **auto start** after host rebooting
* **safe**
  * **certs** are **automatically** generated and updated
  * **secrets** are auto-generated at init stage
  * **disguise** with three layer, hard to be detected by GFW
  * **global proxy** for all you APPs by using vpn

## Prerequisites

* vps with static ip, ports 80,443 are open, ports 1024,51820 are free
* successfuly domain resolution to your vps
* `docker compose`, `dnsutils`, `qrencode`

## Server Side

1. `git clone https://github.com/dusmart/vpn2fly.git && cd vpn2fly`
2. `bash init.sh ${YOUR-DOMAIN}`
3. `docker compose up -d`

see step by step [tutorial](./azure-debian.md) on a purely new debian azure vm

## Mobile Client

* download any v2ray client to your phone
  * [OneClick](https://apps.apple.com/us/app/oneclick-safe-easy-fast/id1545555197) for iOS
  * [SagerNet](https://github.com/SagerNet/SagerNet) for Android
* you can copy the vmess link at init stage, choose **import from clipboard**
* you can also scan the qrcode generated at init stage

## MacOS Client

1. `brew install v2ray`
2. copy the `client.json` generated on server to your mac, v2ray's config file is usually located at `/opt/homebrew/etc/v2ray/config.json`
3. `brew services start v2ray`
4. install the free [wireguard](https://apps.apple.com/us/app/wireguard/id1451685025?mt=12) in app store
5. add the config in `vpn2fly/wireguard/peer1/peer1.conf` on server to client side

## Windows Client

1. download [v2ray-core](https://github.com/v2fly/v2ray-core/releases) and extract, version must be lower than **5.0** such as [4.45.2](https://github.com/v2fly/v2ray-core/releases/download/v4.45.2/v2ray-windows-64.zip)
2. copy the client.json generated on server to your v2ray-core folder
3. `v2ray.exe -config client.json`. If it prompts *An attempt was made to access a socket in a way forbidden by its access permiss*, restart Internet Connection Sharing(ICS) in service.msc or use command `net stop hns && net start hns` , it may help you
4. install the free [wireguard](https://www.wireguard.com/install/)
5. add the config in `vpn2fly/wireguard/peer1/peer1.conf` on server to client side

---

## Roadmap

- [x] Remove all mannual configs from macos VPN client
- [x] Add more client tutorial
    - [x] free macOS client
    - [x] free iOS client
    - [x] free android client
    - [x] free windows client
- [ ] Add one command for macOS's system proxy quick switch, see [v2rayx's switch code](https://github.com/Cenmrev/V2RayX/blob/master/v2rayx_sysconf/main.m) and [install code](https://github.com/Cenmrev/V2RayX/blob/master/V2RayX/install_helper.sh) here

## Acknowledgments

* [Docker Compose](https://github.com/docker/compose)
* [JonasAlfredsson/docker-nginx-certbot](https://github.com/JonasAlfredsson/docker-nginx-certbot)
* [v2fly/v2ray-core](https://github.com/v2fly/v2ray-core)
* [linuxserver/wireguard](https://github.com/linuxserver/docker-wireguard)

## Illustration for MacOS Client Usage

### how to find v2ray's default config file location

* `brew services --json` will show you a plist file for v2ray
* `cat ${v2ray.plist}` will show you what's the command to start v2ray
* see the `ProgramArguments` after `-config`, it is the config file that will be used

### config the socks5 and http proxy for system proxy

* find the proxy in your system proxy (search `proxy` in system settings)
* set http and https proxy to 127.0.0.1:8002
* set socks5 proxy to 127.0.0.1:1082

```mermaid
flowchart LR
    subgraph socks5/http only
        direction LR;
        subgraph client
            direction TB;
            APP--socks5/http proxy-->v2ray-c;
            v2ray-c--ws-->v2ray-c;
        end
        subgraph server
            direction BT;
            nginx--ws-->v2ray-s;
        end
        client--wss-->server;
    end    
```

### use vpn over v2ray

* open/close the switch in wireguard or system settings are both OK

```mermaid
flowchart LR
    subgraph vpn mode
        direction LR;
        subgraph client
            direction TB;
            APP-->vpn-c;
            vpn-c--udp-->v2ray-c;
            v2ray-c--ws-->v2ray-c;
        end
        subgraph server
            direction BT;
            nginx--ws-->v2ray-s;
            v2ray-s--udp-->vpn-s;
        end
        client--wss-->server;
    end    
```

[contributors-shield]: https://img.shields.io/github/contributors/dusmart/vpn2fly.svg?style=for-the-badge
[contributors-url]: https://github.com/dusmart/vpn2fly/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/dusmart/vpn2fly.svg?style=for-the-badge
[forks-url]: https://github.com/dusmart/vpn2fly/network/members
[stars-shield]: https://img.shields.io/github/stars/dusmart/vpn2fly.svg?style=for-the-badge
[stars-url]: https://github.com/dusmart/vpn2fly/stargazers
[issues-shield]: https://img.shields.io/github/issues/dusmart/vpn2fly.svg?style=for-the-badge
[issues-url]: https://github.com/dusmart/vpn2fly/issues
[license-shield]: https://img.shields.io/github/license/dusmart/vpn2fly.svg?style=for-the-badge
[license-url]: https://github.com/dusmart/vpn2fly/blob/main/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 