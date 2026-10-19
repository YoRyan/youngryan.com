---
title: 2026 Home Server Hardware List
author: Ryan Young
categories:
  - tech
---

The objective was simple: Build a home server with ECC memory, lots of space for NVMe drives and 3.5" hard drives, fast Ethernet networking, and as low a power draw as possible. As it happened, this task ended up consuming the last year or so of my computing hobby, so I figured I'd memorialize my struggle with a short epitaph.

#### Motherboard: Kontron K3851-R ATX

This R680E board is jam-packed with features: ECC memory, PCIe bifurcation (to split PCIE1 into two x8 lanes), Intel AMT (for remote control over LAN), and support for consumer LGA1700 CPU's. Best of all, I was able to acquire a new example for an affordable price. The Asus W680 is the most readily available competitor, and it easily would have cost me double.

#### CPU: Intel Core i5-13500T

It packs tons of cores, is engineered for an ice-cold 35W TDP, and OEM pulls are as cheap as dirt on eBay. It also supports ECC and AMT when used with the Kontron board.

#### Cooler: Cooler Master Hyper 212

It cools the CPU and it comes with a reasonably big chunk of metal for $20.

#### PSU: Cooler Master MWE Gold 850 V3

Yes, it's only a "B" on Reddit's favorite PSU tier list, but it excels in one particular stat: low-idle power efficiency. At a near-idle 20W power draw, it's 83% [efficient](https://www.cybenetics.com/evaluations/psus/2478/), which is a class-leading number. I own several spare PSU's, but I specifically bought this unit new to take advantage of its high efficiency and shave off a couple of watts of 24/7 consumption. At the heavily discounted price I acquired it, I expect the payoff—with California electricity prices—to be about 10 years, which matches perfectly with the warranty period. Worth it!

#### PCIe: Asus Hyper M.2 x16 Gen5

It's hilariously oversized, but it's the only NVMe bifurcation card I could find that specifically advertises support for Intel's x8x8 bifurcation mode. The cheaper Chinese cards, including one that I also own, generally only support x4x4x4x4. (And, no, that mode is not compatible with LGA1700 in any configuration; the lanes will not split.)

#### Idle Power Draw: 20-25W

Hey, for 32GB of ECC, 2.5GbE Ethernet, six NVMe drives, and a hard drive, that's pretty good! Especially when compared with the 1000W setups you can find on r/homelab.

## Bits of Accumulated Wisdom 

* For 24/7 systems that will spend a lot of time idling, there really is only one correct answer: Buy Intel. At this time of writing, even AMD's newest silicon (Ryzen 5 9600X) idles at 40W. Switching to Team Blue netted an immediate 38% in savings on my power bill.
* There might not actually be an entire [army](https://robotatx.com/amd/) of "Advanced Marketing Deception" influencers astroturfing for Team Red, but the Internet hive mind could afford to take a collective pause before automatically recommending Ryzen for any and all PC builds. For a home server application, the idle power tax hike is real.
* Because they have a completely different architecture compared to the mainline desktop processors, Ryzen APU's are considerably more energy efficient, especially at idle loads. Unfortunately, AMD has yet to bless any of their consumer APU's with support for ECC memory. The so-called "PRO," OEM-only models do have it, so they look pretty tempting, but attempting to acquire one is a fool's gamble. The vast majority of examples are PSB-locked, which means they are unable to boot in a motherboard that doesn't match the first vendor the processor was installed in. And, no, eBay sellers will not be able to tell you in advance whether their wares are PSB-locked.
* 13th and 14th gen Intel processors are great deals used, thanks to Intel's degradation scandal tarnishing the brand's reputation… unless the processor in question is an unlocked i7 or i9 model, in which case it very likely already is degraded. Unpack an Nvidia driver installer several times to check for degradation. (Seriously, this works.)
* To find out how efficiently a PSU performs at low power draw, skip the Reddit threads and go straight for the Cybenetics certification—their data are meticulously collected and readily accessible. All PSU's are less efficient at lower wattages, but for some the loss is not so bad.

*This plaque is to commemorate the brave pirates who gave their lives to keep this box safe from the robot menace. Lest we forget.*