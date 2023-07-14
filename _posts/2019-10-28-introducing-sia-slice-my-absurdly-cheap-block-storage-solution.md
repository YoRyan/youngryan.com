---
title: Introducing Sia Slice, My Absurdly Cheap Block Storage Solution
author: Ryan Young
type: post
date: 2019-10-28T07:23:38+00:00
permalink: /2019/10/introducing-sia-slice-my-absurdly-cheap-block-storage-solution/
categories:
  - tech
tags:
  - cryptocurrency
  - programming
  - project

---
{% include figure.html image="https://raw.githubusercontent.com/wiki/YoRyan/sia-slice/transfer-screen.png" caption="Sia Slice in action. (On a remote system, with tmux.)" captionmarkdown="true" %} 

I dabble in cryptocurrencies, occasionally. I hesitate to get too partisan on a subject the Internet takes _very_ seriously, but it seems to me that the fairest judge of a coin&#8217;s value is the utility it provides to its holders. So Bitcoin is useful because everyone recognizes and accepts Bitcoin, Monero is useful because it facilitates anonymous transactions, Ethereum has that smart contracts thing going for it, and so on and so forth.

<!--more-->

I&#8217;m pleased to endorse [Sia](https://sia.tech) as another rising star in the cryptocurrency world. It&#8217;s a blockchain-backed decentralized storage network that connects renters with hosts, who sell spare hard drive capacity on a globe-spanning swarm of machines that range from Raspberry Pis to university datacenters. Redundancy and encryption for your files, of course, come standard. Remember &#8220;Pied Piper,&#8221; the fictional peer-to-peer storage network from Mike Judge&#8217;s _Silicon Valley_? Well, Sia is exactly that, except it&#8217;s a real system you can store real data on.

Still, it is clearly a work in progress. The official Sia client nicely handles uploads and downloads, but it lacks support for automatic synchronization, making for an experience that feels especially _manual_ compared to, say, OneDrive or Google Drive. There are a number of promising projects (currently in beta) poised to change this: [Repertory](https://bitbucket.org/blockstorage/repertory/src/master/) mounts Sia storage as a local filesystem, while [Siasync](https://github.com/tbenz9/siasync) keeps files synchronized with Sia. But for maximum flexibility, system administrators and enterprise customers would desire _block-level_—not file-level—access. Very large files, like database dumps, are poorly suited for Sia, which currently does not support partial file updates. And any file synchronization solution would fail to preserve inodes, permissions, and other extended metadata, stripping specialized filesystems like ZFS and Btrfs (both copy-on-write, with support for instant snapshots and data de-duplication) of the very features that make them useful.

The solution is to treat your data not as a collection of files, but as one big, mutable array of bytes. Enter Sia Slice: a small Python program that splits any large file into 100-megabyte chunks for uploading to Sia. Because Sia Slice operates at the block level, it can make 1:1 copies of block devices, disk images, database backups, and other large blobs of data. And on subsequent syncs, it can accomplish partial writes by ignoring the chunks that haven&#8217;t changed.

You can obtain a copy, peruse the source code, and find usage instructions on the project [homepage](https://github.com/YoRyan/sia-slice).

## Notes on Sia

Sia is an emerging platform, so it&#8217;s not just the user interface that is rough around the edges; there is also room for improvement, in my humble opinion, in the developer API. I know the Sia developers are reading this, so I promise to be gentle. 🙂

  * The blockchain, which as of writing is about 17GB large, takes several _days_ to sync on a mechanical hard drive, even if [bootstrapped](https://siawiki.tech/daemon/bootstrapping_the_blockchain). Yikes! A solid-state will bring that time down to hours. There ought to be a polite, but very visible warning on the Sia download page.
  * The API documentation is occasionally outdated or incorrect. For example, the call to validate a SiaPath is [listed](https://sia.tech/docs/#renter-validate-siapath-post) as `/renter/validate/*`, while the correct call `/renter/validatesiapath/*` is shown right there in the example demo!
  * JSON timestamps for access times, modification times, etc. are not represented accurately. In the examples, the timestamps are front-loaded with an unexplained series of numbers, and they also lack quote delimiters, implying they are something other than regular JSON strings.
  * Bindings for languages that aren&#8217;t Go are scarce. For my choice of Python, both [pysia](https://github.com/jnmclarty/pysia) and [siapy](https://github.com/lolsteve/siapy) are over 2 years out-of-date, and missing calls. For Sia Slice, I had to write my own bindings—something I would have had to do anyway to take advantage of Python&#8217;s asyncio features.
  * Sia is said to be most efficient with many simultaneous uploads, but my own experience with the daemon—perhaps it&#8217;s my pokey 10Mbps residential connection—is that it generally limits itself to one upload at a time. When uploading data with `/renter/uploadstream`, it is best to use one POST request at a time; otherwise, the uploads may starve each other for computation time.
  * Presumably due to host or network availability hiccups, Sia occasionally fails to complete an upload, leaving it stuck in a stalled state with less-than-one redundancy. If your uploads are not disk-backed—because you&#8217;ve used `/renter/uploadstream`, perhaps—Sia [considers](https://gitlab.com/NebulousLabs/Sia/blob/master/modules/renter/README.md) that file **lost** and will not repair it on its own; you need to invoke `/renter/delete` and start over. This was a major pitfall that left me scratching my head for several days while the stalled uploads kept piling up. Sia Slice&#8217;s solution is to restart uploads that have not completed within 3 hours.
  * Nitpicking here: `/renter/uploadstream` lacks a specific method for handling failed or aborted POST requests due to a disconnect, program crash, etc. So when Sia Slice uploads data to Sia, it appends a .part extension—just like your web browser or download manager—to disambiguate between successful and failed partial uploads.
  * Some of the file attributes are difficult to understand. What is the difference between `available` and `recoverable`? Why do most of my uploads get `stuck` right out of the gate?
  * Deleting directories with `/render/dir` is not reliable. After several unit tests failed to clean up after themselves, I simply elected to delete individual files instead.

Lastly, I would suggest a new feature that may prove indispensable to end users: bandwidth throttling. Most home networks are afflicted by an insidious phenomenon [called](https://www.bufferbloat.net/) _buffer bloat_—when the relatively slow upload pipe is completely saturated by traffic, packets from other connections stop getting through. Ping times spike. Web browsing becomes sluggish. Skype and Discord calls become pixelated, then cut out entirely. In general, buffer bloat makes the whole Internet feel unreliable and unusable. (That goes for the download direction too, because TCP ACK replies are also impacted.)

It&#8217;s not a concern on my own network, thanks to my high-tech home router with traffic-shaping capabilities; but my neighbor, who is very generously allowing me to &#8220;borrow&#8221; his faster connection for my oversize initial upload, is not so fortunate. For lack of a bandwidth control in Sia, I had to use an OS-level tool like [wondershaper](https://github.com/magnific0/wondershaper) to avoid crippling his digital lifestyle.

## However you slice the problem&#8230;

Some challenges and gotchas aside, building on top of Sia is totally viable; I found the API cleanly designed and intuitive to use. Sia Slice is now &#8220;in production&#8221; as part of my backup workflow—I use [btrbk](https://github.com/digint/btrbk) to save semi-automated snapshots of all my desktops and servers to an external hard drive, and then I mirror that hard drive to the Sia cloud with Sia Slice, thus constituting a 3-2-1 backup strategy. For me, this was a fun project that involved a wide array of systems, from low-level disk access to asynchronous I/O to curses to HTTP streaming.

While the general &#8220;split, hash, compress, and upload&#8221; principle behind Sia Slice could be extended to other kinds of object storage, the simple fact of the matter is that no service on the horizon is nearly as affordable (or decentralized!) as the Sia network. [Dropbox](https://www.dropbox.com/buy) and [Wasabi](https://wasabi.com/cloud-storage-pricing/) both quote USD $12/month for the 2TB of storage I use. On Sia, I pay approximately USD $1/month.

Once again, what is the true purpose of cryptocurrency? To provide useful services that no other medium can—something we all tend to forget as we keep our eyeballs glued to the red and green numerals on cryptocurrency exchanges. Block storage that is a whopping 92% below market cost is certainly very useful to me. Perhaps Sia Slice will make Sia useful to you.