from ipaddress import ip_network
import sys

start = '0.0.0.0/0'
exclude = ['10.0.0.0/8','172.16.0.0/12','192.168.0.0/16'] # private ips
exclude.append(sys.argv[1]) # add your vps's location to the array so that the vpn can bypass the v2ray's client-server connection, it should look like 8.8.8.8

result = [ip_network(start)]
for x in exclude:
    n = ip_network(x)
    new = []
    for y in result:
        if y.overlaps(n):
            new.extend(y.address_exclude(n))
        else:
            new.append(y)
    result = new

print(','.join(str(x) for x in sorted(result)))
