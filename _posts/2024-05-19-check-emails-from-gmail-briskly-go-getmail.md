---
title: "Check Emails From Other Accounts in Gmail—Briskly—With Go-Getmail"
author: Ryan Young
categories:
  - tech
---

> TL;DR Use [go-getmail](https://github.com/mback2k/go-getmail) to sync your indie, IMAP inbox to another IMAP inbox supported by Gmailify like Outlook.com in combination with Gmailify to achieve a (nearly) perfect Gmail setup.

For as long as I can remember being a sentient Internet user, I have called myself a Gmail addict. I remember chatting with online buddies in the embedded Google Talk widget. I remember claiming two extra gigs of storage by enabling 2-factor authentication when it first became available for Google accounts. I remember when the Internet was going all goo-ga for Google Inbox.

I love Gmail because it integrates so well with the rest of the Google ecosystem: your contacts, your calendar events, your Drive attachments. Microsoft and Apple’s offerings are catching up, but they’re still grappling with the Web 2.0 concept of the web browser as a first-rate client, something Google has been mastering since the turn of the century. Add to that synergy the rest of Gmail’s power features—automatic categorization for incoming messages, precision spam detection, a world-class search engine with custom operators, among various other goodies—and I’m honestly not sure if I could ever possibly leave Gmail. I’m hooked, no matter how many privacy scandals Google keeps embroiling itself in.

I love Gmail so much that I refuse to use any other webmail platform to interact with my email. That includes my secondary addresses I have with other providers (shout-out to [Purelymail](https://purelymail.com/)) and the public address that I publish on my website and social profiles. I mean, reading and writing mail _without_ feasting my eyes on Google’s beautiful material design language? The horror!

So I insist on importing all my mail into my Gmail inbox. Seems pretty easy, right? After all, Google even offers some officially supported [methods](https://support.google.com/mail/answer/21289?hl=en). Well, as anyone who has ever looked at this problem has doubtlessly figured out, it is in fact _not_ so simple. It turns out there is no obvious way to connect Gmail with an external inbox in such a way as to accomplish all of the following at the same time:

* Little-to-no delay in delivery time
* Reliable delivery of all messages, including ones that look like spam
* Support for Gmail’s automated filters and classifiers

Call it the holy grail—or whatever faith-agnostic metaphor you prefer—of Gmail integration, but whatever it is, it has always been seemingly unattainable. Until now.

First, I’ll explain what doesn’t work, and then I’ll explain the solution that I finally arrived at.

## Just use forwarding!

Setting your external inbox to forward everything to your Gmail address is the most obvious technique. At first glance, this works alright. Every email provider offers forwarding, it’s nearly instantaneous, and Gmail runs all its magic classifiers on the forwarded messages.

The problem is when your external address receives mail that is spam, or even looks vaguely like spam.

The email protocol is such that it appears to Gmail your external email provider—not the true sender of the message—is the entity who “sent” the spam. And when Gmail receives too many spam-y messages (forwarded or not) from a single server, it gets a little antsy about accepting any more, and simply blackholes _any_ further messages (whether they look like spam or not) from that server for several hours. I emphasize that this isn’t just a little delay in the delivery timeline, nor just a one-way trip to your spam folder, but poof, gonzo, into the digital void your messages go—for hours at a time. And neither the forwarding server, nor the original sender of your email, receives _any_ notification that this is what’s happening to your precious messages.

Now, _you_ might think _your_ email address is squeaky clean and would only receive a miniscule amount of spam, but you have to multiply this particular scenario by everyone _else_ using your particular provider to forward their messages to Gmail. You see, _their_ spam also tests Gmail’s tolerance. So, when you rely on email forwarding from an indie provider like Purelymail, it’ll work great most of the time, but every few days, you’ll have several hours of downtime when Gmail will go all Quiet Place on your communications. And your senders won’t know a thing.

Not good. Onto the next solution.

## What about Gmailify?

Should forwarding not meet your needs, Gmail offers an official product, called “[Gmailify](https://support.google.com/mail/answer/6304825),” to import mail from an external inbox. It’s easy to use and it does exactly what it says on the tin. The problem is that this service is only offered for well-known webmail providers, which presently includes Yahoo, AOL, Hotmail, and Outlook—probably companies Google was able to work out some kind of API access arrangement with.

By contrast, if you want to connect a mailbox that isn’t from one of the big providers, Google allows this, but only through a POP3 import job that needs to be run on a regular basis. You don’t receive your mail until Gmail does its thing. And, there’s the rub: Google schedules these jobs at _their_ convenience, not yours.

(POP3, for some background, is an ancient protocol used to retrieve mail from an email inbox. It’s simple to implement, but it’s a _polling_ protocol, which means you need to initiate a new connection with the email server and start from scratch every time you want to check for new messages. It’s the digital equivalent of having to drive to the post office to see if you have any mail, every single time. Apparently, this is a not-insignificant drain on Google’s resources, because they schedule checks of your inbox on intervals as infrequently as up to an hour apart. It's worse than waiting for a city bus.)

The exact algorithm used to determine how frequently to poll your inbox, as with so many things Google, is not publicly known, and is subject to much speculation by desperate users trapped in the depths of Google’s support forums. The Internet’s best guess is that it has something to do with how frequently your external inbox has emails to retrieve when Gmail checks it. Cue the people who have taken to [sending](https://rakowski.pro/how-to-force-gmail-to-check-your-pop3-account-as-often-as-possible/) automated emails to themselves to trick Google into thinking their inbox is more popular than it really is. This is, clearly, quite the hack, and I have seen reports that even this trick does not work consistently.

If you use a well-known webmail service like Yahoo or Outlook, the Gmailify experience is excellent—emails arrive within just a couple of minutes of being received upstream. It is only when using an indie provider that you get downgraded to the “delivered, whenever, maybe even slower than the actual post office” tier.

I spent years living with Gmail’s sloth of a POP3 importer, mostly being annoyed by the delay in receiving my mail, which could be anywhere from 15 to 60 minutes, depending on Google’s mood. It wasn’t so bad for bank statements and marketing emails, but for 2FA exchanges and conversations with real live humans, the limitations were… painfully apparent.

On Gmail’s desktop interface, at least, I could request a manual POP3 refresh by navigating through a maze of menus and finding the particular link. Clicking the refresh button is supposed to do this too, but in true Google fashion, that feature has been [broken](https://support.google.com/mail/thread/130772496) since forever, with no sign of a fix. (I cannot vouch for any of the paid Chrome extensions.) On the Android app, big surprise, I was screwed: No button to request a POP3 refresh to be found anywhere. By logging into Purelymail’s web interface, I could at least read the messages, even if they hadn’t yet been retrieved by Gmail. But what if I needed to reply to one? Could I really be expected to do that outside of Gmail? The horror!

## My first forwarder: Turbogmailify

Not being satisfied with either of the official methods, I wondered if I might be able to build a better mail forwarder by writing some code. Gmail, after all, still has a publicly accessible API—a relic from the days when Google was built by and for nerds. The [user.messages.import](https://developers.google.com/gmail/api/reference/rest/v1/users.messages/import) call quickly caught my eye, and it seemed to be exactly what I was looking for: a way to import messages into my account on my own terms. To quote the description:

> Imports a message into only this user's mailbox, with standard email delivery scanning and classification similar to receiving via SMTP.

It would have been a piece of cake to retrieve messages from my Purelymail inbox with POP3, just as Google does, except, obviously, more frequently. But I wasn’t going to settle for that—I wanted _instant_ delivery of new messages. Enter the IMAP protocol, the successor to POP3 in all but name, which includes many more features—among them, the ability to maintain an indefinite connection to an IMAP server and get notified when new messages arrive in a mailbox. (The digital equivalent of having the post office call you when it’s time to go retrieve your mail.)

So the task was to log in to my IMAP account, wait for notifications of new messages, copy the messages to Gmail, and then delete the messages from the original server. After a few hours hacking together some Go code, I had a working prototype. I call the result “[turbogmailify](https://github.com/YoRyan/turbogmailify/).”

Sadly, it was after all this work that I learned that Google’s definition of “classification” does not include Gmail’s automatic labeling features. The import call simply dumps messages into the All Mail folder and you must explicitly specify the labels you want to apply to each message; there is no way to instruct Gmail to work its magic and decide for itself which labels to apply.

This limitation might be acceptable if all you wanted to do was import an archive of your previous mail—as, coincidentally, an official Google Python [script](https://github.com/google/import-mailbox-to-gmail) does—but it’s no good for receiving real, live mail. I had to look for another solution.

## Final answer: go-getmail

The IMAP protocol has another useful feature: Not only can you download email from an IMAP server, you can also upload it—just as you might upload files to Google Drive for storage and eventual retrieval. This capability is how you can sign into multiple accounts with a desktop email client and drag and drop emails between accounts.

Gmail, like most other webmail providers, has support for IMAP. A thought occurred to me: What if we had a real-time, IMAP to IMAP forwarder? And there just so happens to be a little Go program, [go-getmail](https://github.com/mback2k/go-getmail), that is exactly that. It retrieves mail from one IMAP server and uploads it to another, while also deleting the mail from the original server.

At first, this approach doesn’t look to be any more promising than using the Gmail API, because once again, there’s no way to ask Gmail to classify the mail that you insert for you. Gmail exposes all its labels as IMAP folders, and dumping messages into the “Inbox” folder merely appends them without any labels. There’s no IMAP command to ask Gmail to apply its magic labels.

Then I wondered: What if I used, as my IMAP destination, an inbox that Gmail supported with Gmailify? Maybe, I crossed my fingers, Gmail wouldn’t perceive any difference between the synchronized messages and real “live” messages, and would import and classify them accordingly? And maybe, just maybe, Gmail would fetch these emails far more frequently, with Gmailify briskness rather than POP3 lethargy?

Noting that my Outlook.com inbox has support for both IMAP access and Gmailify, I quickly created a go-getmail configuration file and gave this harebrained scheme a shot: Purelymail to Outlook.com to Gmail.

And it works! And it’s—almost—perfect! Fast delivery, no spam black hole, automatic classification. The Gmail holy grail!

With one exception: Gmail perceives imported emails from “sensitive” senders (think banks, and for some reason, the USPS) as suspicious and automatically marks them as spam. No big deal—I’ll simply provide my real Gmail address to senders that Gmail consistently flags. Otherwise, this setup is close enough to perfect that I’m more than happy to live with this quirk.

## Summary

At long last, I’ve arrived at a Gmail-with-external-inboxes setup that seems as close to perfect as possible.

| Method                | Latency       | Reliability | Gmail Magic |
| --------------------- | ------------- | ----------- | ----------- |
| Forwarding            | 🚀            | ❌          | 🚀          |
| Check with POP3       | 👎            | 🚀          | 🚀          |
| Turbogmailify         | 🚀            | 👍          | ❌          |
| Go-getmail + Gmailify | 👍            | 👍          | 🚀          |

To run go-getmail 24/7, I’ve deployed it as a Docker container inside my home server, while retaining Gmail’s POP3 importer as a backup for when my homelab goes down. Go-getmail, just like my own turbogmailify, takes advantage of IMAP’s real-time mailbox notifications, so it swipes the emails from Purelymail before Gmail’s lethargic importer ever bothers to look.

In the future, I want to extend go-getmail so that I can selectively choose messages not to forward. That way, if I still have problems with Gmail marking certain messages as spam, I can leave them for Gmail to import on its own. (Yes, I promise to upstream my code.)

I have a love/hate relationship with Google. Picture this: You’re going on a nice jog, enjoying all of this truly outstanding technology, but when something goes wrong, or you brush up against the limitations, it feels like encountering a locked gate in the middle of your walking path—you _should_ be able to get through there, but you can’t, for the most arbitrary and opaque of reasons. In a sense, maybe this is only fair. If a service is free, then you are the product—or at least shouldn’t feel entitled to some good old-fashioned customer service from a faceless Big Tech behemoth.

But, just this once, I’m happy I get to say: Sorry, Big Tech. Score one for the nerds.

## Postscript: My homelab configs

My Docker Compose snippets for go-getmail:

```yaml
services:
  go-getmail:
    image: ghcr.io/mback2k/go-getmail
    container_name: go-getmail
    restart: unless-stopped
    configs:
      - source: go-getmail.yaml
        target: /etc/go-getmail/go-getmail.yaml

configs:
  go-getmail.yaml:
    content: |
      Accounts:
        - Name: Purelymail to Outlook
          Source:
            IMAP:
              Server: imap.purelymail.com:993
              Username: bob@example.com
              Password: supersecret
              Mailbox: INBOX
          Target:
            IMAP:
              Server: outlook.office365.com:993
              Username: bill@outlook.com
              Password: hunter2
              Mailbox: INBOX
      Logging:
        Level: warn
```

My custom Dockerfile for go-getmail (because you really should build your own image for something so sensitive that it handles your _email_, and I like to save space with [scratch](https://hub.docker.com/_/scratch) images):

```dockerfile
FROM golang:1-alpine AS build
RUN apk add --no-cache ca-certificates
WORKDIR /src
COPY . .
RUN go mod download
ENV CGO_ENABLED=0 GOOS=linux
RUN go build -a -installsuffix cgo -o ./out/go-getmail .
FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /src/out/go-getmail /main
USER 10001
ENTRYPOINT ["/main"]
```