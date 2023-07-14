---
title: Print Your Stuff from the Terminal with utprint.py
author: Ryan Young
type: post
date: 2017-07-03T07:26:30+00:00
permalink: /2017/07/print-your-stuff-from-the-terminal-with-utprint/
ampforwp-amp-on-off:
  - default
categories:
  - tech
tags:
  - python
  - utexas

---
Recently &#8212; in the spring of 2016, I believe &#8212; the UT Austin libraries rolled out a new printing system that allows students and staff to upload documents via a web interface. This was a huge deal to me because previously, I had to get off my laptop and sign in to a library computer to print things.

{% include figure.html image="/assets/posts/wp-uploads/2017/07/utprint_pharos.jpg" caption="Functional but frustratingly slow." captionmarkdown="true" %}

It works well enough, but as is always the case for university computer systems, it&#8217;s a little cumbersome to use. My typical workflow looked like this:

  1. Log in
  2. Upload my essay
  3. Set my standard printing options: no color, duplex

That works out to about ten clicks and a password manager access. The horror! We can do much better. _We have the technology._

Over the last two weekends, I put together a Python script that can send documents straight from the command line. It stays authenticated for two weeks at a time and there&#8217;s a configuration file to specify preferred printing settings.

<pre>$ ./utprint.py ~/Documents/utcs.pdf
Print settings:
  - Full color
  - Simplex
  - Copies: 1
  - Page range: all
Logging in with saved token ... done
Uploading utcs.pdf ... done
Processing ... done
Finances:
    Available balance: $1.16
    Cost to print:     $0.42

    Remaining balance: $0.74</pre>

I&#8217;m sure it will prove useful to all the&#8230; one&#8230; UT Austin students who are handy with a terminal and do a lot of writing. Find it on [GitHub](https://github.com/YoRyan/utexas-lib-print).