---
title: Black Screen When Booting Arch Linux Installer via UEFI
author: Ryan Young
type: post
date: 2014-05-11T22:46:40+00:00
draft: true
private: true
permalink: /2014/05/black-screen-when-booting-arch-linux-installer-via-uefi/
categories:
  - tech

---
Today on my laptop, I decided to reinstall GRUB (the bootloader) and use UEFI booting instead of the good old-fashioned IBM BIOS system.

Well, turns out that when I booted the Arch Linux installer off my USB stick to finish a critical part of the process, I got a black screen.

Lots of people have the same issue with their UEFI machines, and the normal solution is to disable KMS and modesetting. However, that didn&#8217;t work for me, which makes sense because it&#8217;s not as if the choice of UEFI or BIOS booting is going to magically affect the way the graphics works.

The solution that worked for me &#8211; gleaned from the [darkest corner of the Internet][1] &#8211; was to disable the Ethernet card in the BIOS. Yes, really.

Well, I ain&#8217;t questioning it!

 [1]: https://bbs.archlinux.org/viewtopic.php?pid=1269115#p1269115