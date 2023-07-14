---
title: 'A Farewell to Arms: Why I’m Quitting Linux on the Desktop'
author: Ryan Young
type: post
date: 2020-12-30T09:37:40+00:00
permalink: /2020/12/a-farewell-to-arms-why-im-quitting-linux-on-the-desktop/
categories:
  - tech
tags:
  - linux
  - windows

---
It goes without saying that 2020 has been the year of the inconceivable. And to top it all off, after daily driving Linux on my laptop for nearly a decade, I just switched back to Windows!

Let me explain—it&#8217;s not as if I&#8217;ve given up on the Penguin OS entirely. My servers and routers continue to run Linux, delivering funny cat pictures to myself and dispatching my own hot takes to the rest of the Internet. Without question, Linux is the perfect OS for those roles, being flexible, performant, reliable, and cheap. With LXD containers, I can spin up a fresh, isolated Linux system in seconds to try out a piece of software or run my own experimental code. And with Linux&#8217;s plethora of logical volume and filesystem options, I can build any conceivable kind of software-defined storage solution. My personal trio of LUKS, Bcache, and Btrfs, for example, allows me to keep my home server fully encrypted, with a 256GB SSD-backed cache and fully automated incremental backups.

This kind of flexibility would not be possible on any other OS, let alone at no cost whatsoever. But it was when I would close out my terminal window and switch back to my desktop that the appeal of Linux would begin to diminish—because if you spend any amount of time working in both &#8220;houses&#8221; of Linux, it becomes obvious which side receives the lion&#8217;s share of the community&#8217;s development efforts and resources. While server-side Linux is backed by the engineering might of Big Tech, from Red Hat to Novell to Microsoft to the NSA, desktop-side Linux is maintained largely by the goodwill of open-source volunteers. The Linux ecosystem, quite simply, resembles a tale of two cities.

Building and maintaining a fully open-source desktop environment, like KDE or GNOME, is no small feat, and I still harbor immense respect for the programmers, testers, and managers who donate hours of their time to keep these projects going. But even so, it&#8217;s clear to me that volunteer labor has its limits.

In short, here&#8217;s why I made the switch to Windows.

## Linux on the desktop is kind of slow and mediocre.

Conventional wisdom holds that if you want to do your computing on a low-end system like a Windows XP laptop or Raspberry Pi, that installing and using a lightweight Linux distribution is your best bet. So, how can I justify my assessment? While it&#8217;s true that a stripped-down Linux install with something like LXDE or Openbox will feel &#8220;lighter&#8221; than a Windows shell and generally consume less resources, it is not a given that it will perform any faster, nor even that it will save any energy.

Take web browsing—in today&#8217;s digital landscape, I spend at least 90% of my time on the computer using some online application or service that runs in a web browser, which I always keep open and permanently pinned to my taskbar. So, as you can imagine, it&#8217;s quite critical that my web browsing experience be as zippy and responsive as possible. Unfortunately, a smooth web browsing experience continues to elude me on Linux. The Linux versions of Firefox and Chromium are noticeably sluggish compared to their Windows counterparts running on identical hardware; it only takes a few hours of uptime for the telltale signs of &#8220;browser rot&#8221; to emerge, from slow page rendering to irritating freezes to snowballing memory consumption numbers. Inevitably, the situation becomes untenable and I have to close and restart my browser—something I&#8217;m forced to do at least once, sometimes even multiple times per day. This has been a consistent issue throughout my decade-long journey with Linux, from Ubuntu to Arch to Fedora.

If I had to speculate, I&#8217;d hazard to guess that the Linux&#8217;s GPU acceleration is not up to the task and, in some manner, causes browser engines to exhibit degraded performance and persistent memory leakage. It&#8217;s well-known that graphics acceleration in Linux can be a complete mess to develop for, but it&#8217;s not like I&#8217;m playing with exotic hardware here—just the Intel HD Graphics chip that comes standard with every el cheapo laptop on the market. In the geeky, nuts-and-bolts side of the tech press, you hear all the time about how the Linux kernel is pushing the boundaries of computer graphics through GPU-accelerated virtual machines, optimizations for TensorFlow, and other applications that sound super useful on a server or mainframe. But all of that means diddly squat to Joe Average desktop user, who just wants a good experience browsing the web at 60 fps. Once again, solutions aplenty for server users, but crumbs for desktop users.

Power consumption is another one of Linux&#8217;s sticking points. Browsing on Linux is not just slower compared to browsing on Windows; it also tends to run your system hotter and spin up its fans more frequently. On a form factor and energy-constrained laptop, that matters, a lot. Playing a YouTube video? On Windows, web browsers can use GPU-accelerated video decoding, which maximizes energy efficiency. But on Linux, this is basically impossible, so your battery gets sapped like the fuel tank of a Hummer and your fans get pegged at Boeing 747-like decibel levels. And don&#8217;t get me started on the more powerful laptops with AMD and Nvidia graphics cards in on-the-fly switching configurations, which are basically not supported by Linux, period.

None of this is to place the blame squarely on the Linux community or Linus Torvalds. Look, I get it—It&#8217;s extremely difficult to program graphics drivers, particularly when the vendors conceal their secret sauce and developers must reverse-engineer their products. But when your operating system performs so miserably on modern hardware, you have to ask yourself whether using it is really a badge of honor—a manifestation of your &#8220;1337 Unix skills&#8221;—or a questionable alternative to the factory-provided operating system that supports everything out of the box, and does that operating system-type stuff pretty well.

## Windows is an impressive product these days!

I jumped ship to Ubuntu during the Windows Vista era. Remember what a debacle Vista was? The awful performance; the buggy drivers; the nanny-like User Account Control; that Vista bomb defusal skit on _The IT Crowd_?

As we all know, Windows 7 righted many of these wrongs, but I felt it was still a markedly inferior choice compared to using any Linux distribution. First of all, Windows Update _sucked_—waiting for it to work its magic entailed monk-like patience, and God help you if you had to reinstall Windows 7 from scratch and thereby install the complete catalog of updates released by Microsoft. Second, hardware autodetection also sucked. If you moved a Windows 7 installation to a new system, or made a major change to your hardware configuration, there was a pretty good chance that your system would stop booting entirely, forcing you to reinstall. Third, if you were a programmer, Linux was unquestionably the kind of environment you had to have, with software compilers and interpreters at the tips of your terminal-savvy fingers.

And then Windows 8 came out, which made the case for switching to Linux even stronger.

But fast forward to 2020, and Windows 10 is&#8230; actually a significantly improved and more usable operating system. Windows Update is speedy (okay, _maybe_ not quite as zippy as it could be) and unobtrusive, and it downloads, installs, and updates hardware drivers automatically. Gimmicks that were once Linux exclusives, like multiple desktops and indexed file searching, come standard in the Windows 10 shell.

Not to mention, stuff _just works_. Like my Firefox browser, and my network printers, and the extremely useful circular scrolling motion on my Synaptics touchpad (which I believe was dropped from the Linux driver years ago). And have you seen the swanky new [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) app? It&#8217;s easily on par with any desktop Linux console.

## Everything that I needed on Linux is now available on Windows.

One of Linux&#8217;s killer features used to be the package manager in the form of APT, Yum, pacman, etc. It was so much easier to download and update software from a centrally managed repository rather than acquiring it individually from the Internet, especially when you consider that every program on Windows has to maintain its own background updater service—if it even has an automatic updater at all.

But now you can get that experience on Windows, too.

The Chocolatey package manager, which is an awesome project, lets you search, install, and update Windows software from a curated community repository—just as you can do with APT, Yum, pacman, etc., right down to the `choco install` and `choco upgrade` commands, which mirror their Linux counterparts.

To run many developer tools, like Ruby and Apache, you&#8217;ll still need a working copy of Linux. But now, those binaries can run on Windows, too, thanks to Microsoft&#8217;s Windows Subsystem for Linux initiative. WSL version 1 facilitates near-seamless interoperability between Linux binaries and the Windows kernel, filesystem, and network stack, which means I can run my developer tooling without any of the overhead of a full Linux virtual machine.

For me, this was the game changer that led me to contemplate switching back to Windows—being a Linux programmer is no longer synonymous with actually having to run Linux. WSL really does feel like magic, and I hope Microsoft upholds their promise to maintain it in spite of their current development focus on WSL version 2. (Version 2 swaps the novel system call translation employed by WSL version 1 for an ordinary virtual machine, making it significantly, in my opinion and in [the opinions of many others](https://github.com/microsoft/WSL/discussions/4022), less interesting.)

## Conclusion—Et tu, Brute?

Linux, we&#8217;ve had some good times together. Like schooling Java-averse classmates in Data Structures 314, or pimping out the desktop with &#8220;1337 h4x0r&#8221; Conky monitors, or laughing in the face of Lenovo&#8217;s Superfish debacle.

But when I can accomplish my programming (and non-programming) work faster and more efficiently on Windows, that means it&#8217;s time to make the switch. It&#8217;s only the rational thing to do.