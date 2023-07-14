---
title: Creating a Guest Network with a Tomato Router
author: Ryan Young
type: post
date: 2014-04-14T01:55:58+00:00
permalink: /2014/04/creating-a-guest-network-with-a-tomato-router/
categories:
  - tech

---
Here are my notes on how to portion off a guest wireless network for&#8230; you know, guests&#8230; if you have a router powered by the excellent Tomato third-party firmware. (I run [Tomato RAF](http://victek.is-a-geek.com/) on a Linksys E4200.)

It&#8217;s not meant to be an exhaustive guide, because there are a few already on the Internet. Rather this is how I achieved _my_ specific setup:

  * Do not allow guests to make connections to the router, thus preventing them from accessing the web interface or making DNS requests.
  * Firewall guests from the main network and any connected VPN&#8217;s.
  * Push different DNS servers and a different domain to the guest network.

First you&#8217;ll need to create a separate VLAN and a virtual SSID for your guest network. My router has two antennas, so I could have used a dedicated antenna for the guest network, but I opted to use a virtual SSID anyway because the second antenna is used for the 5 GHz band.

By default, VLAN 1 is the LAN and VLAN 2 is the WAN (the Internet). So, I created VLAN 3 for my guest network. I then attached a virtual wireless network on wl0.1 named [openwireless.org](http://openwireless.org).

This is where most guides stop, since Tomato already firewalls the new guest network from the rest of your LAN. Instead of bothering to tweak the firewall, they simply advise you to set a strong administrator password on the web interface.

This didn&#8217;t satisfy me, though &#8211; I wanted firewall-level separation. Also, the guest network is still able to access any VPN&#8217;s the router is running. So here&#8217;s some iptables magic:

<pre># Add a special forward chain for guests. Accept all Internet-bound traffic but drop anything else.
iptables -N guestforward
iptables -A guestforward -o vlan2 -j ACCEPT
iptables -A guestforward -j DROP
iptables -I FORWARD -i br1 -j guestforward

# Add an input chain for guests. Make an exception for DHCP traffic (UDP 67/68) but refuse any other connections.
iptables -N guestin
iptables -A guestin -p udp -m udp --sport 67:68 --dport 67:68 -j ACCEPT
iptables -A guestin -j REJECT
iptables -I INPUT -i br1 -j guestin</pre>

This goes in Administration > Scripts > Firewall. Simple and easy to understand. Note that &#8216;br1&#8217; is the network bridge for your guest network and &#8216;vlan2&#8217; is the WAN VLAN. You probably don&#8217;t have to change these.

Last thing that bothered me was that Tomato by default assigns both networks the same DNS and domain settings. This means that guests can make DNS queries to your router for system hostnames, like &#8216;owl,&#8217; and get back legitimate IP addresses. Overly paranoid? Probably, but here&#8217;s the fix:

<pre># DNS servers for guest network
dhcp-option=tag:br1,6,208.67.222.222,208.67.220.220
# Domain name for guest network
dhcp-option=tag:br1,15,guest</pre>

This goes in Advanced > DHCP/DNS > Dnsmasq custom configuration. Combined with the iptables rules above, this will force your guests to not use the router&#8217;s DNS.

Once again, &#8216;br1&#8217; is the guest bridge. You can also specify your own DNS servers instead of OpenDNS.

And there you have it &#8211; a secure network for your own devices and a guest network, carefully partitioned off from everything else, solely for Internet access.

There are two pitfalls with this setup: no bandwidth prioritization and the possibility that someone could do illegal things with your IP address.

I don&#8217;t really care about bandwidth, because I already have a QoS setup, and I live in a suburban neighborhood so users of my guest network will be few and far between.

However, I am considering forcing all my guest traffic through the Tor network. That may be a future post.