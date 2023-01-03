# setup on a purely new debian server on azure

## create vm

1. use [azurespeedtest](https://www.azurespeed.com/Azure/Latency) to test the latency, decide which datacenter you will use
2. use [azureprice](https://azureprice.net/?_numberOfCores_max=1&_memoryInMB_max=1&sortField=linuxPrice&sortOrder=true) to compare the price for different vms, we'll only need 1 cpu core and 0.5 GB memory
3. images `ubuntu 22.04` and `debian 11` are all tested successfully, they're recommended
4. make the ports 22, 80, 443 public

## install docker compose

ref from docker doc [here](https://docs.docker.com/engine/install/) if you're not using **debian**

```sh
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release 
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
```

## install some tools

```sh
sudo apt-get install -y qrencode dnsutils
sudo usermod -aG docker ${USER}
```

## setup our nginx-certbot and v2ray as well as wireguard

**logout and re-login** to take the group adding in effect

```sh
git clone https://github.com/dusmart/vpn2fly.git && cd vpn2fly
bash init.sh ${YOUR-DOMAIN} # use your own domain here to replace ${YOUR-DOMAIN}
```

the success log will contain these important configs

* vmess link and a qrcode: you can scan this qrcode or copy the link and import it from clipboard to your mobile v2ray client APPs, your mobile phone will be able to use the v2ray
* your secret id in v2ray: use this if you want to import the config to your phone mannually, add it by choose `VMESS` -> set `Address` to `your domain ip` -> `Port` remains default `443` -> set `ID` to `your secret id in v2ray` -> `Enable TLS` -> set `ServerAddress` to `your domain` -> set `Stream Setting` to `ws` -> set `Host` to `your domain` -> set `Path` to `/lazy`

## run the containers in the background

```sh
cd vpn2fly
docker compose up -d
```

the success log will look like this

```sh
 ⠿ v2fly-core Pulled                                 13.6s
   ⠿ 2408cc74d12b Pull complete                       2.2s
   ⠿ 4f4fb700ef54 Pull complete                       2.4s
   ⠿ c6b373c46cb7 Pull complete                       2.7s
   ⠿ b0ec1e70028e Pull complete                      10.7s
[+] Running 4/4
 ⠿ Network vpn2fly_vpn2fly  Created                   0.1s
 ⠿ Container nginx-certbot  Started                   6.3s
 ⠿ Container v2fly-core     Started                   1.3s
 ⠿ Container wireguard      Started                   1.8s
```

you should wait for a while at the first time, because applying cert will take you some seconds

## about the logs

* `docker logs -f wireguard` will show you the vpn client config file, you should see a qrcode here, it is actually the content of `vpn2fly/wireguard/peer1/peer1.conf`
* `docker logs -f v2fly-core` will show the `Reading config: /etc/v2ray/config.json`, you can view v2ray's access log in `vpn2fly/v2fly-core/access.log`
* `docker logs -f nginx-certbot` will show that it could not find the cert and has applied new cert for you, you can also see the logs from nginx here
