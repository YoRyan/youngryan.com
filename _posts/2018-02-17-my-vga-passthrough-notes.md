---
title: My VGA Passthrough Notes
author: Ryan Young
type: post
date: 2018-02-17T17:00:37+00:00
permalink: /2018/02/my-vga-passthrough-notes/
featured_image: /assets/posts/wp-uploads/2019/02/VGAPassthru.jpg
categories:
  - tech
tags:
  - vga passthrough

---
#### Introduction: What is VGA passthrough? {#introductionwhatisvgapassthrough}

Answer: Attaching a graphics card to a Windows virtual machine, on a Linux host, for near-native graphical performance. This is evolving technology.

This post reflects my experience running my VGA passthrough setup for several years. It is not intended as a complete step-by-step guide, but rather a collection of notes to supplement the existing literature (notably, Alex Williamson&#8217;s [VFIO blog](https://vfio.blogspot.com)) given my specific configuration and objectives. In particular, I am interested in achieving a smooth gaming experience, maintaining access to the attached graphics card from the Linux host, and staying as close to a stock Fedora configuration as possible. Hopefully, my notes will be useful to someone.

<!--more-->

#### Objectives {#objectives}

  * Play Windows games with good performance and minimal virtualization-induced stuttering.
  * Use integrated graphics on the Linux host. However, make my graphics card available as a secondary device for CUDA, cryptocurrency mining, etc. when the guest isn&#8217;t running.
  * Use the facilities provided by Fedora for virtual machine and system administration, including libvirt and systemd.
  * Make all CPU cores available to the guest.
  * Make all CPU cores available to the host at all times.
  * Integrate with KDE&#8217;s PulseAudio instance and use software audio mixing.

#### Hardware {#hardware}

My target platform is a 2014-era Haswell Refresh desktop.

  * Motherboard: ASRock H97M Pro4
  * Processor: Intel Core i5-4690 (4 cores/4 threads)
  * Memory: 24GB DDR3
  * Integrated graphics: Intel HD Graphics 4600
  * Passthrough graphics: Nvidia GeForce GTX 1060 6GB
  * Storage: 240GB SSD (host /, guest C:), 1TB HDD (host /home), 1TB HDD (guest E:)
  * Displays: 3x Dell 1905FP (1280&#215;1024, 1x VGA/1x DVI-D)

#### Software {#software}

My motherboard is configured to boot using integrated graphics. On the ASRock H97M, this setting is buggy and I also have to turn on CSM support.

  * Host: Fedora 27 x86_64
  * Desktop environment: KDE 5
  * Hypervisor: libvirt
  * Guest: Windows 10 64-bit

#### Host configuration {#hostconfiguration}

Use Alex Williams&#8217;s [VFIO passthrough guides](https://vfio.blogspot.com/2015/05/vfio-gpu-how-to-series-part-1-hardware.html) as a reference. The first few entries begin with determining the capabilities of your hardware and configuring your kernel for VGA passthrough.

Some notes from my setup:

  * Since I only have one graphics card, IOMMU groups are not a problem on my consumer board. Thus, I do not need the ACS override patch.
  * The 1060 is an EFI-capable card, so I can boot the guest in EFI mode. This means I do not have to deal with VGA arbitration.
  * I do not bind my 1060 to `pci-stub` because I want to use its compute capabilities on the host. In this case, the proprietary `nvidia` driver will happily be bound/unbound automatically by libvirt. 
      * Sometimes `nouveau` is stubborn about loading, even when it is blacklisted, so I also boot with `nouveau.modeset=0`, which allows me to `modprobe -r nouveau` at runtime.
      * Unbinding `nvidia` while processes are still running on it will cause the card to unrecoverably lock up.
  * Use `options kvm ignore_msrs=1` to avoid fatal CPU exceptions in the Windows guest in certain games.

#### Guest configuration {#guestconfiguration}

Use Alex Williamson&#8217;s [&#8220;Our first VM&#8221; chapter](https://vfio.blogspot.com/2015/05/vfio-gpu-how-to-series-part-4-our-first.html) as a reference, assuming your graphics card features EFI mode. Williamson also has a [chapter for BIOS mode](https://vfio.blogspot.com/2015/05/vfio-gpu-how-to-series-part-5-vga-mode.html) that is slightly more complicated. In addition, here are some tips I&#8217;ve discovered to achieve better and smoother performance.

#### CPU performance and stuttering {#cpuperformanceandstuttering}

As described on Williamson&#8217;s blog, turn on and use hugepages for slightly better CPU performance. **As of November 2017, Fedora 27&#8217;s selinux rules block libvirt from launching guests with hugepages. [Active bug report.](https://bugzilla.redhat.com/show_bug.cgi?id=1514538)**

Virtual machines stutter due to context switches and other CPU activity on the host, which is particularly noticeable in resource-intensive games like _Grand Theft Auto IV_. To some extent, this is a limitation of the technology. However, there are some things you can do to mitigate it:

  * Pin your virtual CPU&#8217;s to physical CPU&#8217;s in a 1:1 ratio.

<pre class="wp-block-code"><code>  &lt;cpu mode='host-passthrough' check='none'>
    &lt;topology sockets='1' cores='4' threads='1'/>
  &lt;/cpu>
  &lt;cputune>
    &lt;vcpupin vcpu='0' cpuset='0'/>
    &lt;vcpupin vcpu='1' cpuset='1'/>
    &lt;vcpupin vcpu='2' cpuset='2'/>
    &lt;vcpupin vcpu='3' cpuset='3'/>
  &lt;/cputune></code></pre>

  * Assign maximum real-time priority to the guest&#8217;s IO thread.

<pre class="wp-block-code"><code>&lt;iothreads>1&lt;/iothreads>
&lt;cputune>
  &lt;iothreadsched iothreads='1' scheduler='fifo' priority='99'/>
&lt;/cputune></code></pre>

  * In the Windows guest, force MSI interrupts on for all PCI devices using a utility like [this one](https://github.com/CHEF-KOCH/MSI-utility). [(Here&#8217;s Williamson on why this helps.)](https://vfio.blogspot.com/2014/09/vfio-interrupts-and-how-to-coax-windows.html)

#### A word on CPU shielding {#awordoncpushielding}

If you want to stop the virtual machine from stuttering completely, the only complete solution is to dedicate entire cores to the guest. You can [do this at boot-time](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#CPU_pinning_with_isolcpus), using the `isolcpus` parameter, or at runtime, using cgroups and a helper script like [cpuset](https://github.com/lpechacek/cpuset).

Neither solution is acceptable to me given that I only have 4 physical cores. (In hindsight, it would have been worth paying more for a Core i7.) In my case, the virtual CPU pinning and scheduling tweaks reduced the stuttering to a comfortable level.

#### Disk performance {#diskperformance}

For much-improved IO performance, [turn on the data plane implementation in virtio-scsi](http://blog.vmsplice.net/2013/03/new-in-qemu-14-high-performance-virtio.html). This seems to fix slow, high-latency disk writing for tasks like Steam downloads.

#### Audio configuration {#audioconfiguration}

libvirt&#8217;s emulated ich6/ich9 sound card works fine for sound output and is actively developed. Stick with it.

You have several options for routing the audio from the guest to the host:

  * Keep the virt-manager graphical monitor open, even though the guest does not even use the emulated display. _Simple and easy._
  * Configure Qemu to connect to your desktop environment&#8217;s PulseAudio instance. _Slightly harder to set up, but no monitor needed._
  * Passthrough a PCI device, whether that&#8217;s the graphics card&#8217;s audio controller or the integrated audio controller. _You lose access to that device on the host._
  * Passthrough a USB audio controller and use a loopback cable. _Needs extra hardware and is kind of a kludge, if you ask me._
  * Send audio over the network using something like JACK. _Crazy difficult to set up between Windows and Linux._

#### Using PulseAudio {#usingpulseaudio}

I choose to connect to PulseAudio, which I&#8217;ll describe in detail here.

First, configure a virtual input in PulseAudio by opening an anonymous socket. This should work regardless of your DE.

<pre class="wp-block-code"><code># in ~/.config/pulse/default.pa
.include /etc/pulse/default.pa
load-module module-native-protocol-unix auth-anonymous=1 socket=/tmp/ryan-pulse</code></pre>

Then add the required Qemu options to libvirt.

<pre class="wp-block-code"><code>&lt;domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
  ...
  &lt;qemu:commandline>
    &lt;qemu:env name='QEMU_AUDIO_DRV' value='pa'/>
    &lt;qemu:env name='QEMU_PA_SERVER' value='unix:/tmp/ryan-pulse'/>
  &lt;/qemu:commandline></code></pre>

On Fedora, selinux prohibits this configuration out of the box. You can let Qemu fail to start and then add your own exception to whitelist it.

<pre class="wp-block-code"><code>setsebool -P virt_use_xserver 1
ausearch -c 'qemu-system-x86' --raw | audit2allow -M my-qemusystemx86
semodule -X 300 -i my-qemusystemx86.pp</code></pre>

#### Networking {#networking}

For simplicity, I use macvtap in bridge mode attached to the host&#8217;s Ethernet interface. For host-to-guest communication, I have a second virtual NIC attached to a standalone bridge. This preserves compatibility with NetworkManager.

#### Sharing the keyboard and mouse {#sharingthekeyboardandmouse}

The emulated mouse provided by virt-manager is imprecise and produces too much CPU stuttering for gaming, so you&#8217;ll probably need a way to share your keyboard and mouse between the host and the guest.

For an easy, off-the-shelf solution, you can purchase [Synergy](https://symless.com/synergy). Be sure to enable relative mouse movements so you can play first-person shooters.

Synergy produces some weird behavior in a few games, like freezing in _Halo 2 Vista_, so I rolled my own script to attach/detach my USB keyboard and mouse to/from the guest.

<pre class="wp-block-code"><code>#!/bin/bash

MOUSE='046d c52b'
KEYBOARD='2516 0009'

DOMAIN=$1
if [[ -z "$DOMAIN" ]]; then
        echo Usage: $0 "DOMAIN [switch back timer]"
        exit 0
fi
SWITCHTIME=$2
DEVICE_FILE=''
export LIBVIRT_DEFAULT_URI='qemu:///system'

function make_device()
{
        vendor=$1
        product=$2
        file="/tmp/hostdev-$vendor:$product.xml"
        echo "&lt;hostdev mode='subsystem' type='usb'>" >$file
        echo '  &lt;source>' >>$file
        echo "    &lt;vendor id='0x$vendor'/>" >>$file
        echo "    &lt;product id='0x$product'/>" >>$file
        echo '  &lt;/source>' >>$file
        echo '&lt;/hostdev>' >>$file
        DEVICE_FILE=$file
}
function attach_usb()
{
        vendor=$1
        product=$2
        make_device $vendor $product
        virsh attach-device "$DOMAIN" $DEVICE_FILE
}

function detach_usb()
{
        vendor=$1
        product=$2
        make_device $vendor $product
        virsh detach-device "$DOMAIN" $DEVICE_FILE
}

function usb_is_attached()
{
        vendor=$1
        product=$2
        virsh dumpxml "$DOMAIN" | grep -q "&lt;vendor id='0x$vendor'/>" && \
                virsh dumpxml "$DOMAIN" | grep -q "&lt;product id='0x$product'/>"
}

if usb_is_attached $KEYBOARD; then
        detach_usb $MOUSE
        detach_usb $KEYBOARD
elif [[ -n "$SWITCHTIME" ]]; then
        attach_usb $MOUSE
        attach_usb $KEYBOARD
        sleep $SWITCHTIME
        detach_usb $MOUSE
        detach_usb $KEYBOARD
else
        attach_usb $MOUSE
        attach_usb $KEYBOARD
fi

exit 0</code></pre>

In Windows, I have an AutoHotkey script to send the &#8220;switch back&#8221; command over ssh.

#### Sharing files {#sharingfiles}

Besides Windows file sharing, you may be interested in [Swish](https://sourceforge.net/projects/swish/), an SFTP plugin for Windows Explorer.