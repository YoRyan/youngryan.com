---
title: 'BIOS Mods and Integrated GPU’s: a Tale of Hybrid Graphics'
author: Ryan Young
type: post
date: 2015-03-19T07:04:30+00:00
draft: true
private: true
permalink: /2015/03/bios-mods-and-igpus-a-tale-of-hybrid-graphics/
categories:
  - tech

---
Well, today I called it quits with my designated &#8220;home gaming&#8221; laptop. It was a HP dv7t-6000 laptop with the following equipped:

  * CPU: Intel Core i7-2630QM
  * Integrated GPU: Intel HD Graphics 3000
  * Discrete GPU: AMD Radeon HD 7400M

Despite being augmented with a discrete GPU, its gaming performance was never anything to write home about. However, I had been keeping it serviceable for the last couple years by using modified AMD graphics drivers from [Leshcat][1]. The performance was slightly improved with the newer drivers, especially with games like Wargame: Red Dragon that were released long after HP had ceased supporting the machine&#8217;s software.

This month, however, during a routine upgrade to the latest Leshcat release, it appeared that my discrete graphics stopped working. Programs were suddenly reporting that they were being run on the HD Graphics 3000 iGPU.

I&#8217;m still not sure what happened but I think that the latest Leshcat release dropped support for older &#8220;fixed&#8221; switchable graphics. Thus, I was now using &#8220;dynamic&#8221; switchable graphics, which means that work done by the iGPU is offloaded to the dGPU. Programs still see the active graphics processor as the HD Graphics 3000 even though the 7400M is doing all the work.

In the process of figuring all this out I discovered that the InsydeH2O BIOS that comes with many HP laptops actually has a [few hidden screens][2] that grant access to a plethora of settings.

The advertised easy method (F10 + A) didn&#8217;t work for me, so naturally the next step was to flash [a modded BIOS][3] &#8211; which not only granted access to the secret settings but also removed the infamous HP wireless card whitelist.

With switchable graphics working again (after forcing the now-modded BIOS to use &#8220;dynamic&#8221; mode to work with Leshcat), my graphics performance was back but seemed&#8230; lackluster.

The benchmarks confirmed this. Here are the PassMark scores for every laptop GPU I&#8217;ve ever owned:

  * Nvidia GeForce 310M: [221][4]
  * AMD Radeon HD 7400M: [634 (?)][5]
  * Intel HD Graphics 4600: [726][6]

That&#8217;s right, the entry-level integrated graphics from 2013 smoked the 2010 and 2011-era discrete GPUs. It&#8217;s surprising what difference a couple of years can make.

I&#8217;ve now retired the Sandy Bridge HP. My Haswell laptop, of all things, now holds the crown for the most powerful GPU in the household.

 [1]: http://leshcatlabs.net/
 [2]: http://blog.falcondai.com/2012/02/insyde-bios-advanced-settings.html
 [3]: http://donovan6000.blogspot.com/2013/12/modded-bios-repository.html
 [4]: http://www.videocardbenchmark.net/gpu.php?gpu=GeForce+310M&id=102
 [5]: http://www.videocardbenchmark.net/gpu.php?gpu=Radeon+HD+7640G+%2B+7400M+Dual&id=2442
 [6]: http://www.videocardbenchmark.net/gpu.php?gpu=Intel+HD+4600&id=2451