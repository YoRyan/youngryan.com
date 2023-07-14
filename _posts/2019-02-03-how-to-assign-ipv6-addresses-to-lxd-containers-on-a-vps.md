---
title: How to Assign IPv6 Addresses to LXD Containers on a VPS
author: Ryan Young
type: post
date: 2019-02-03T17:00:56+00:00
permalink: /2019/02/how-to-assign-ipv6-addresses-to-lxd-containers-on-a-vps/
categories:
  - tech
tags:
  - ipv6
  - vps

---
_This post was rewritten on July 26, 2019 to incorporate a cleaner solution. The original version can be viewed [here](https://web.archive.org/web/20190727025117//2019/02/how-to-assign-ipv6-addresses-to-lxd-containers-on-a-vps/)._

LXD is my favorite containerization stack. For my use case, which is running various services on the same machine with isolated root filesystems, it&#8217;s more flexible and easier to use than Docker, particularly in terms of networking capabilities.

Using LXD, I can bridge all of my containers to my local LAN, thereby providing each of them a unique local IPv4 and global IPv6 address. This makes it very easy to forward ports and set firewall rules to open services to the outside world—no more fumbling around with awkward `PORT` directives and multiple levels of NAT44, as is the case in Docker land.

But this setup gets complicated when you use attempt to use LXD on a commodity Virtual Private Server (VPS), because the IPv6 configuration these providers use is rather strange and counter-intuitive. (I&#8217;ll tell you exactly why when we get there.) So, here is how you can get globally routable, public-facing IP addresses for your containers on your $30/year VPS, without any application-level hacks like TCP/UDP proxying, port forwarding, or that abomination known as NAT66.

**The Setup:** The host is a VPS running Ubuntu, or your choice of contemporary distribution. The provider has allocated a virtualized network interface, `net0`, to connect to the Internet with IPv4 and IPv6 addresses. The containers will be attached to `lxdbr0`, a bridge interface managed by LXD.

<pre class="wp-block-code"><code>$ ip link show
...
2: net0: &lt;BROADCAST,MULTICAST,ALLMULTI,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 54:52:00:4f:5c:b3 brd ff:ff:ff:ff:ff:ff
3: lxdbr0: &lt;BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether fe:34:61:66:1b:ae brd ff:ff:ff:ff:ff:ff</code></pre>

So far, every VPS seller I&#8217;ve purchased from assigns each customer an entire /64 &#8220;prefix&#8221; (or a small subset of a prefix, or even a single address), but instead of using prefix delegation to advertise and route this prefix—as an Internet provider or cellular operator with native IPv6 would—they unceremoniously dump your server, and the servers of your &#8220;neighbors,&#8221; onto a common /48 prefix with a static gateway.

The following table, copied verbatim from my VPS provider&#8217;s network configuration page, suggests this is the result of a misguided attempt to translate a legacy IPv4 configuration into IPv6-speak:

IP Address           |Gateway       |Netmask
---------------------|--------------|-------------
2602:ff75:7:373c::/64|2602:ff75:7::1|/48
104.200.67.206       |104.200.67.1  |255.255.255.0

**The Red Herring:** You can&#8217;t just bridge your containers with `net0`, because the VPS&#8217;s network usually drops traffic from unexpected MAC addresses. Try it yourself: run `ip link set net0 address 112233445566` and see if you lose connectivity.

## The Solution

Delegate your /64 prefix, or some subset of it, to `lxdbr0`, and configure LXD to use your choice of SLAAC or DHCPv6 to assign addresses to your containers. Then use the [NDP Proxy Daemon](https://github.com/DanielAdolfsson/ndppd) to advertise the presence of your containers to the wider /48 prefix.

#### Set up LXD networking

Assign an IPv6 prefix to `lxdbr0` with LXD. If you allocate your entire /64, you may use SLAAC:

<pre class="wp-block-code"><code>$ lxc network set lxdbr0 ipv6.address 2602:ff75:7:373c::1/64</code></pre>

But if you want to reserve parts of your prefix for other purposes, you must use stateful DHCPv6:

<pre class="wp-block-code"><code>$ lxc network set lxdbr0 ipv6.address 2602::ff75:7:373c::ea:bad:1/112
$ lxc network set lxdbr0 ipv6.dhcp.stateful true
$ lxc network set lxdbr0 ipv6.dhcp.ranges 2602::ff75:7:373c::ea:bad:2-2602::ff75:7:373c::ea:bad:255 # optionally</code></pre>

Sample configuration:

<pre class="wp-block-code"><code>$ lxc network show lxdbr0
config:
  ipv4.address: none
  ipv6.address: 2602:ff75:7:373c::1/64
  ipv6.dhcp: "false"
  ipv6.firewall: "true"
  ipv6.nat: "false"
  ipv6.routing: "true"</code></pre>

#### Set up host networking

You must use on-link addressing for `net0`; do not attach the shared /48 prefix. If the prefixes assigned to two different interfaces (e.g., a /48 on `net0` and a /64 on `lxdbr0`) overlap, dnsmasq [will seemingly fail to send Router Advertisements](https://discuss.linuxcontainers.org/t/ipv6-configuration-times-out/5146), breaking automatic IPv6 configuration.

On Ubuntu, netplan is supposed to be able to configure this, but [the on-link addressing option is currently broken for IPv6](https://bugs.launchpad.net/ubuntu/+source/netplan.io/+bug/1785493). (May 2020 update: Micha Cassola of Foundyn found a way to accomplish this with pure netplan; see <a rel="noreferrer noopener" href="https://discuss.linuxcontainers.org/t/getting-universally-routable-ipv6-addresses-for-your-linux-containers-on-ubuntu-18-04-with-lxd-4-0-on-a-vps/7322" target="_blank">this thread</a>.) Therefore, you must use ifupdown, augmented with some scripted iproute2 glue:

<pre class="wp-block-code"><code># apt install ifupdown
# cat >>/etc/network/interfaces
auto net0
iface net0 inet static
        address 104.200.67.206/24
        gateway 104.200.67.1
        up ip -6 address add 2602:ff75:7:373c::/128 dev net0
        up ip -6 route add 2602:ff75:7::1/128 onlink dev net0
        up ip -6 route add default via 2602:ff75:7::1
        down ip -6 route delete default via 2602:ff75:7::1
        down ip -6 route delete 2602:ff75:7::1/128 onlink dev net0
        down ip -6 address delete 2602:ff75:7:373c::/128 dev net0</code></pre>

Your IPv6 routing table should thus resemble:

<pre class="wp-block-code"><code>$ ip -6 route show
2602:ff75:7::1 dev net0 metric 1024 pref medium
2602:ff75:7:373c:: dev net0 proto kernel metric 256 pref medium
...
default via 2602:ff75:7::1 dev net0 metric 1024 pref medium</code></pre>

#### Set up NDP proxying

Finally, use ndppd to make your containers &#8220;appear&#8221; on the same broadcast domain attached to `net0`. Here is a sample configuration file (for further information, see [the manual](http://manpages.org/ndppdconf/5)):

<pre class="wp-block-code"><code># cat >/etc/ndppd.conf
proxy net0 {
    rule 2602:ff75:7:373c::/64 {
        iface lxdbr0
        router no
    }
}</code></pre>

Alternatively, you can use the kernel&#8217;s builtin NDP proxy facility. You have to insert each address one-by-one, and the command does not stick across reboots:

<pre class="wp-block-code"><code># sysctl -w net.ipv6.conf.all.proxy_ndp=1
# ip -6 neighbour add proxy 2607:f8b0:4004:811::2 dev net0
# ip -6 neighbour add proxy 2607:f8b0:4004:811::3 dev net0
...</code></pre>

#### Conclusion

You&#8217;re all done!

<pre class="wp-block-code"><code>$ lxc list
+------------+---------+------+--------------------------------------------+------------+-----------+
|    NAME    |  STATE  | IPV4 |                    IPV6                    |    TYPE    | SNAPSHOTS |
+------------+---------+------+--------------------------------------------+------------+-----------+
| container1 | RUNNING |      | 2602:ff75:7:373c:216:3eff:fedd:3f4e (eth0) | PERSISTENT | 0         |
+------------+---------+------+--------------------------------------------+------------+-----------+
| container2 | RUNNING |      | 2602:ff75:7:373c:216:3eff:fe5d:5f6a (eth0) | PERSISTENT | 0         |
+------------+---------+------+--------------------------------------------+------------+-----------+</code></pre>

<pre class="wp-block-code"><code>$ lxc exec container1 -- ip -6 addr show eth0
13: eth0@if14: &lt;BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
    inet6 2602:ff75:7:373c:216:3eff:fedd:3f4e/64 scope global dynamic mngtmpaddr noprefixroute 
       valid_lft 3145sec preferred_lft 3145sec
    inet6 fe80::216:3eff:fedd:3f4e/64 scope link 
       valid_lft forever preferred_lft forever</code></pre>

<pre class="wp-block-code"><code>$ lxc exec container1 -- ip -6 route show
2602:ff75:7:373c::/64 dev eth0 proto ra metric 1024 pref medium
fe80::/64 dev eth0 proto kernel metric 256 pref medium
default via fe80::e432:28ff:fe6c:b421 dev eth0 proto ra metric 1024 hoplimit 64 pref medium</code></pre>

<pre class="wp-block-code"><code>$ lxc exec container1 -- ping -c 4 google.com
PING google.com(bud02s28-in-x0e.1e100.net (2a00:1450:400d:805::200e)) 56 data bytes
64 bytes from bud02s28-in-x0e.1e100.net (2a00:1450:400d:805::200e): icmp_seq=1 ttl=47 time=153 ms
64 bytes from bud02s28-in-x0e.1e100.net (2a00:1450:400d:805::200e): icmp_seq=2 ttl=47 time=153 ms
64 bytes from bud02s28-in-x0e.1e100.net (2a00:1450:400d:805::200e): icmp_seq=3 ttl=47 time=153 ms
64 bytes from bud02s28-in-x0e.1e100.net (2a00:1450:400d:805::200e): icmp_seq=4 ttl=47 time=153 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3003ms
rtt min/avg/max/mdev = 153.202/153.324/153.412/0.486 ms</code></pre>

Enjoy having end-to-end connectivity on your containers, the way the Internet was intended to be experienced.

Post-script: If you still need IPv4 (looking at you, ppa.launchpad.net), you can let LXD handle the NAT44 configuration, or use a [public NAT64/DNS64 gateway](https://go6lab.si/current-ipv6-tests/nat64dns64-public-test/).