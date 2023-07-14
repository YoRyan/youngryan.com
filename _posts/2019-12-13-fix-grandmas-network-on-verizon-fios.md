---
title: How to Fix Grandma’s Network on Verizon FiOS
author: Ryan Young
type: post
date: 2019-12-14T03:40:38+00:00
permalink: /2019/12/fix-grandmas-network-on-verizon-fios/
categories:
  - tech
tags:
  - internet
  - isp
  - networking

---
In my family, the person with the fastest Internet connection is&#8230; Grandma, a Vietnam War refugee who has never used a computer in her life. This is by virtue of her residence on a main road in the great state of Delaware, which gets fiber TV and Internet service through Verizon FiOS. She subscribes to the cheapest Internet plan so that the grandkids can tap away at their tablets during family gatherings. And on FiOS, the &#8220;lowest tier&#8221; is a blazing-fast symmetric connection: 100 Mbps down, 100 Mbps up.

It really isn&#8217;t fair, is it?

Grandma&#8217;s 20th-century tract home, like Grandma herself, was thrust only reluctantly into the digital age. It has no data cabling whatsoever besides two landlines and two coax ports, which, naturally, are both located on the extreme corners of the house—the worst possible positions to place a Wi-Fi access point. So for many years, the family ISP shitbox sat on one end of the house or the other, saddling the opposite side with all of the classic symptoms of crappy Wi-Fi coverage: buffering videos, sluggish webpages, frequent disassociations, and frustrated kids. This fall, I discovered one of my uncles (bless his heart) had attempted to cover the dead spot with a cheap access point and powerline networking kit from TP-Link. Immediately, my heart sank—powerline networking is almost always bad news. I marshaled together two laptops and ran iperf to test the performance of the link. It was a bottleneck&#8230; to put it mildly. On a network with a 100 Mbps uplink, the powerline connection achieved a whopping 12 Mbps.

{% include figure.html image="https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Actiontec_MI424WR_Verizon_front.png/283px-Actiontec_MI424WR_Verizon_front.png" caption="The prehistoric MI-424WR is a dime a dozen on the Philadelphia-area Craigslist." %}

Right then and there, I decided it was time to blow up Grandma&#8217;s home network and start over. It had to go, _all of it_—the extra AP; the powerline adapters; even the Verizon router itself, a venerable Actiontec MI-424WR that hasn&#8217;t received a security patch in over a decade. My plan was to junk everything and install a whole-home Wi-Fi mesh system using Ethernet-over-coax (MoCA) technology for reliable backhaul. (A cross between &#8220;option 9&#8221; and &#8220;option 10,&#8221; for those of you who made their way here from DSL Reports&#8217; [FiOS guide](https://www.dslreports.com/faq/verizonfios/3.1_General_Networking).) We&#8217;re talking 802.11ac, dual-band, wired backbone, baby. At first, I set my sights on Google Wifi, but I found the price tag of Linksys Velop—the economy dual-band model can be had in 2-packs for just $100-150 total—a little more palatable. I wasn&#8217;t worried about cheaping out because, thanks to the MoCA backbone, I wouldn&#8217;t be relying on the performance (or lack thereof) of Velop&#8217;s wireless repeating.

I consider Belkin a third-rate brand, but I have to hand it to them for the job they&#8217;ve done on their Velop product. For example, if you run a home network with multiple access points, it&#8217;s important that they support roaming assistance—the 802.11k, v, and r standards—without which Wi-Fi clients tend to &#8220;stick&#8221; to the first AP they see and refuse to switch to another station, even if the-signal-quality-is-garbage-and-another-AP-is-_right-there_-so-why-the-hell-wouldn&#8217;t-you-switch-god-damnit. In the consumer space, basically nothing supports roaming assistance except for whole-home mesh systems—including, of course, Linksys Velop. Velop also autodetects the presence of an Ethernet connection between its nodes, and makes use of it for backhaul. (Some contemporary mesh systems, unbelievably, lack Ethernet ports altogether!) And bonus points for Velop&#8217;s online management interface; it&#8217;s refreshing to be able to manage a network without installing yet another smartphone app.

For my MoCA adapters, I cheaped out and bought a pair of [Actiontec WCB3000N](https://www.actiontec.com/products/home-networking/wcb3000n/)&#8216;s, which regularly go for $20 each, used. Testing with iperf clocked their maximum speed at about 100 Mbps. (The newest stuff on the market can exceed gigabit speeds, but I couldn&#8217;t justify paying triple the cost for speeds nobody in Grandma&#8217;s house would ever need or use.) Each WCB3000N comes with a pair of very outdated 802.11n Wi-Fi radios, the idea being that the device can act as a coax-backed &#8220;Wi-Fi extender.&#8221; Um, thanks, but no thanks; I&#8217;d just like the MoCA part, please. _But what&#8217;s this? No web interface option to disable Wi-Fi? WTF?!_ Hilariously, there is indeed a control—it&#8217;s just hidden by a little bit of CSS.

{% include figure.html image="/assets/posts/wp-uploads/2019/12/FiOS_SpectrumWCB3000.png" caption="And for my next trick, I shall make the &#8220;Wireless Radio&#8221; checkbox disappear!" %}

You see, WCB3000N&#8217;s are so cheap because the market is flooded with examples that were handed out by ISP&#8217;s. Mine came from Spectrum, who apparently removed the ability to disable Wi-Fi to make their product &#8220;idiot-proof.&#8221; One [brave soul](https://github.com/Saturn49/wecb) on GitHub got the GPL source to compile and released a custom build that restores the missing control. Unfortunately, there&#8217;s one bug still unresolved: The setting to disable the 2.4GHz radio doesn&#8217;t stick after a reboot. Pooey. I turned off SSID broadcast on that network and called it a day.

There are some special considerations to mind when working on a FiOS network. First, the cable boxes require an IP connection to download TV guide data from Verizon. Although some models (including the one my Grandma has) have Ethernet ports, they are not activated, and the connection has to be made using their builtin MoCA adapters. Fortunately, the boxes can link with any commodity MoCA adapter—including the WCB3000N I was using to network the Velops. Second, the remote DVR and on-screen caller ID features won&#8217;t work if a Verizon router isn&#8217;t the gateway. In my case, the loss of neither of these mattered to Grandma&#8230;

Another complication is the connection from the router (my base Velop node) to the Optical Network Terminal on the side of the house, which can be made via either MoCA or Ethernet. Contemporary installs use Ethernet, but older FiOS installs—including, you guessed it, Grandma&#8217;s—used coax, probably so the installers could spare themselves the trouble of running a new Ethernet line. The coax connector on a FiOS-branded router conceals two MoCA adapters: the &#8220;LAN-side&#8221; one, which runs on channel D1 and connects to the cable boxes, and the &#8220;WAN-side&#8221; one, which runs on the less-common channel C4 and connects to the ONT. The use of differing frequencies keeps both MoCA network segments logically separate.

Network Segment|MoCA Frequency|Connected Devices
---------------|--------------|------------------------------------
WAN            |C4            |Router; ONT
LAN            |D1            |Router; cable boxes; Wi-Fi; Ethernet

Running a new Ethernet line wasn&#8217;t an option—Grandma would&#8217;ve strangled me if I broke out the drill and started punching holes in her precious house. So, I needed a MoCA adapter that could operate on channel C4 and talk to the ONT. Turns out these adapters have gone nearly extinct! The [Arris MEB1100](https://www.ebay.com/p/15015261176), which Verizon distributes to FiOS customers, seems to be the only one still in production. But I wondered if it was possible to dodge this purchase by placing Grandma&#8217;s existing FiOS router into bridge mode. The Actiontec web interface has no obvious option to do this; but as it turns out, it _is_ indeed possible!

The key is the &#8220;Network Connections&#8221; screen, which allows you to modify the router&#8217;s internal network topology to your heart&#8217;s content. You can accomplish a bridging configuration by detaching the &#8220;Ethernet/Coax&#8221; interface from the &#8220;Network&#8221; bridge and bridging it with the &#8220;Broadband Connection&#8221; interface. Unfortunately, if your model lacks the ability to separate the Ethernet and coax interfaces, you&#8217;ll have to disable the LAN-side MoCA adapter.

{% include figure.html image="https://web.archive.org/web/20200212202803if_/https://vrzn.i.lithium.com/t5/image/serverpage/image-id/13739iBA528BD6ECE93A8E" caption="(A screenshot found on Google Images. Not my actual configuration!)" %}

By doing this, you&#8217;ll lose all access to the web interface except through the Wi-Fi hotspot, which will become its own, isolated network segment. Just set the SSID to something unique, like `MI424WR_Admin`, and use the same WPA password printed on the unit so that it&#8217;s easy to remember in the event you need to access the configuration screen again. (It&#8217;s not a security concern to keep an Actiontec router in service like this, because the web interface is not accessible from the Internet—or even your own LAN.) Then, when you plug the WAN port of your own router into one of the LAN ports on the Actiontec, your router will receive a public IP address, and you&#8217;ll be off to the races.

So, several equipment overhauls and a few coax splitters later, Grandma&#8217;s network went from this:

![](/assets/posts/wp-uploads/2019/12/FiOS_Ba1.png)

To _this_:

![](/assets/posts/wp-uploads/2019/12/FiOS_Ba2.png)

Did I over-engineer the crap out of it? Probably. But at least you can start a download anywhere in Grandma&#8217;s house and get the full 100 Mbps.