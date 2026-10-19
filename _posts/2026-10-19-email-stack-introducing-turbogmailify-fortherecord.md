---
title: "2026 Email Stack: Introducing Turbogmailify and ForTheRecord"
author: Ryan Young
categories:
  - tech
---

It's 2026 and I'm still hopelessly addicted to Gmail, the red letter "M" forever pinned to the top-left corner of my browser window. In my humble opinion, Google's psychedelic concoction of a web-first interface, powerful filtering tools, reliable push delivery, and seamless integration with Android still cannot be beat. (Among the competition, Outlook is really the only webmail service that comes within spitting distance. Maybe I'll give it the proper college try, someday, if Microsoft ever gets over their love affair with AI slop.) So, big G it is.

Over the last couple of years, I've made some big investments—in blood, sweat, and hours spent staring at VS Code—into the Gmail ecosystem that I figured I would document here, because if you love Gmail as much as I do, I believe these projects have a place in your software stack.

## [Turbogmailify](https://github.com/YoRyan/turbogmailify): Replacement for Gmail's sunset POP3 importer

A quick refresher: Turbogmailify is an IMAP-to-Gmail importer program that was originally intended to complement Gmail's POP3 fetcher, a sloth-like creature that, when it was still among us living netizens, was notorious for taking frequent, hour-long lunch breaks. I last wrote about Turbogmailify in 2024, when I reported it was just a prototype program that I never placed into production use. Well, as it happens, at some point—I cannot recall when, exactly—I ditched the Gmailify + imapsync workflow I documented in that post and actually started using Turbogmailify in combination with the official importer. If I remember correctly, I think I couldn't get imapsync to expunge old messages, so it was filling up my intermediate Outlook inbox? Regardless of the reason, it's satisfying to know that my email is now being handled solely by my own code, and Turbogmailify has proved a reliable workhorse. When Gmail killed off the POP3 importer in January of this year, which set every Gmail power user's collective hair on fire, my setup didn't even miss a beat.

In consideration of such an epoch, I took the opportunity to clean up Turbogmailify's documentation and add support for the (subjectively) simpler TOML configuration format. The authorization flow for Gmail is, unfortunately, still laborious and backrooms-esque, but the path is considerably more well-traveled nowadays by AI agents and the humans that are so eager to use them. Dareisay, there's never been a better time to get in.

But, you say: Why shouldn't I just cough up the $12/year to Gomailify and be done with the forward-my-mail-into-Gmail problem for eternity? My answer is the standard byline for every open-source project: Turbogmailify is the only software that you can audit and modify yourself. You know that nobody else (well, besides Google, or your original mailbox provider, anyway…) will be harvesting your precious messages or their metadata. And unlike suspiciously similar Gmail importer projects that you can find on GitHub, Turbogmailify does not spin up a SQL database, launch a web server, or ask Claude how to solve its problems. It's just a Go daemon that imports mail, with source code that fits into a single file.

Without the aid of any advertising on Reddit or self-hosted forums, Turbogmailify has even picked up a few GitHub stars—and contributors. I am in contact with a handful of regular users who send me issue reports and pull requests, and I am very much grateful for their insights, which have allowed me to build better software. I also think this kind of collaboration could have only been possible given my choice of the Go programming language. Ask Reddit or Hacker News and they'll lecture you that complexity is *better*, that complexity is *necessary*, that a language as simple as Go can only be destined for technological irrelevance, but my experience is that a language as accessible as Go means more eyes and ears on your code. For a tiny program like Turbogmailify that doesn't exactly *need* Rust-level performance, that's an unqualified win.

It should be noted that using the Gmail import API, as Turbogmailify does, still bypasses Gmail's secret-sauce label classifier, so I simply configured my online accounts to send mail directly to my Gmail address. That took care of all the automated crap I'm happy to have Google sort for me, whereas anything delivered to my public address probably came from a human, so I don't want any labels on it, anyway. So while Turbogmailify still isn't a perfect POP3 fetcher replacement, it happens to work very well for me.

## [ForTheRecord](https://github.com/YoRyan/ForTheRecord): Import everything else into your Gmail inbox

Setting up notifications for your self-hosted software can be downright *annoying*. The traditional Linux way has always been email notification via SMTP, which for Gmail loyalists such as myself used to mean creating "app passwords" to authorize each self-hosted service in a way that was compatible with Google's mandatory 2-factor authentication. Well, a few years ago, Google killed that workflow, too.

These days, omni-notification libraries like Apprise are in vogue. The idea is that software authors don't need to incorporate support for every single notification target in existence; they need only attach a library like Apprise, which in turn can send to any service the end user desires. Chat services like Discord and WhatsApp are popular targets (many homelab operators set up a private Discord server just for themselves and their notifications). This was the driving idea behind my Mailrise bridge, which went semi-viral across GitHub and the homelab sphere: Even if a sender only supports traditional SMTP, with Mailrise they can bridge to practically any other service supported by Apprise.

But as far as my own homelab was concerned, I could never settle on an Apprise target that I was completely satisfied with. Ntfy had delayed push notifications and persistent battery drain on Android. Signal required a complex authorization flow and yet another self-hosted bridge. Matrix had awful search capabilities, and I didn't fancy creating a Discord server just for myself and my machines. And on and on.

Finally, I came to the realization that what I really wanted was for my homelab notifications to again be little white rectangles with bold text inside my Gmail inbox. And so, I've gone full circle! I leveraged my experience with the Gmail API to create ForTheRecord, a modern way to receive homelab notifications inside Gmail. You spin up and authorize this one program for your inbox, and it can import notifications from practically every conceivable self-hosted source:

* Omni-libraries like Apprise and Shoutrrr
* Shell scripts and CLI commands firing one-off cURL requests
* And, yes, delivery of complete emails via a mock SMTP server

So far, I'm using ForTheRecord to bridge notifications from Dozzle, Change Detection, Open Media Vault, and several homebrew backup scripts. And it's awesome! Everything just appears in my Gmail tab and app, perfectly formatted. I no longer dread unboxing a shiny new piece of self-hosted software, only to discover a "notifications" tab inside the settings page, thinking to myself: Oh geez, will I actually be able to receive the surely-very-important notifications this thing will generate?

To add some more fuel to the language wars fire: ForTheRecord was an absolute pleasure to write and is an absolute pleasure to maintain because of its use of the F# programming language.

## Conclusion: Subscribe to Gmail+

I am proud to say I am ever closer to becoming a new species of human-Gmail hybrid, and I invite every homelab-savvy fellow member of The Gmail Cult to join me on my journey.
