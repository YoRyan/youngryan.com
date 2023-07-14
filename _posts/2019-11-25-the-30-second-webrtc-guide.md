---
title: The 30-Second WebRTC Guide
author: Ryan Young
type: post
date: 2019-11-26T01:16:43+00:00
permalink: /2019/11/the-30-second-webrtc-guide/
categories:
  - tech

---
(_Web technology changes fast! Mind the date this post was written, which was November 2019.)_

I get the feeling nobody uses WebRTC in the real world, since all of the tutorials use the same toy examples that don&#8217;t involve any actual network connectivity. That&#8217;s a shame, because WebRTC makes peer-to-peer communication a cakewalk. Somewhere in our imaginations, there&#8217;s a whole category of decentralized web apps, just waiting to get written!

Anyway, this post serves as a quick, practical guide to WebRTC. The first thing to realize is that it&#8217;s not just another web API that&#8217;s ready to go out of the box—WebRTC requires three distinct services to work its magic. Fortunately, the browser handles much of the communication behind the scenes, so you don&#8217;t need to worry about all of the nitty-gritty details.<figure class="wp-block-image size-large">

{% include figure.html image="/assets/posts/wp-uploads/2019/11/rtc_diagram.png" width="1285" height="695" alt="A network diagram illustrating the relationships between signalling, STUN, and TURN servers and browsers." caption="The relationships between browsers and servers in WebRTC. Diagram courtesy of [draw.io](https://draw.io)." captionmarkdown="true" %}

<pre class="wp-block-code"><code>let me = { isInitiatingEnd: () => { ... },
           sendToOtherEnd: (type, data) => { ... } };</code></pre>

To use WebRTC, you need some kind of out-of-band signalling system—in other words, a middleman—to deliver messages between the browsers. This is how they exchange the networking information necessary to negotiate a direct connection. Obviously, if they could deliver it directly, then they would have no need for WebRTC!

The design of the signalling system itself is left _entirely_ up to you. Choose any technology you please—WebSocket, QR code, email, carrier pigeon. As we will see, WebRTC provides the necessary hooks to abstract over the underlying technology.

<pre class="wp-block-code"><code>const STUN_SERVERS = { urls: ["stun:stun.l.google.com:19302"] },
      TURN_SERVERS = { urls: "stun:stun.example.com", username: ..., credential: ... };
let rtc = new RTCPeerConnection({ iceServers: [STUN_SERVERS, TURN_SERVERS]});</code></pre>

If you expect your WebRTC session to traverse different networks, your clients will also need access to a **Session Traversal Utilities for NAT** (STUN) server. This is a service that informs browsers of their public IP address and port number, which can only be determined from a host on the public Internet. (STUN servers consume very little resources, so there are many that are freely available.)

Sometimes, despite the browsers&#8217; best efforts, the network topology is too restrictive to achieve a direct connection. When this happens, WebRTC can fallback to a **Traversal Using Relays around NAT** (TURN) server, which is another middleman that can forward network traffic between clients. It&#8217;s like your signalling server, except it uses a standardized protocol explicitly designed for high-bandwidth streams. The more clients need such a middleman, the more bandwidth the TURN server will consume; therefore, if you want one, you will most likely need to run your own.

<pre class="wp-block-code"><code>if (me.isInitiatingEnd())
        rtc.addEventListener("negotiationneeded", async (event) => {
                await sdpOffer = await rtc.createOffer();
                await rtc.setLocalDescription(sdpOffer);
                me.sendToOtherEnd("SDP-OFFER", sdpOffer);
        });
rtc.addEventListener("icecandidate", async (event) => {
        if (event.candidate)
                me.sendToOtherEnd("ICE-CAND", event.candidate);
});

me.receiveFromOtherEnd = async (type, data) => {
        switch (type) {
        case "SDP-OFFER":
                await rtc.setRemoteDescription(data);
                const sdpAnswer = await rtc.createAnswer();
                await rtc.setLocalDescription(sdpAnswer);
                me.sendToOtherEnd("SDP-ANSWER", sdpAnswer);
                break;
        case "SDP-ANSWER":
                await rtc.setRemoteDescription(data);
                break;
        case "ICE-CAND":
                await rtc.addIceCandidate(data);
                break;
        }
};</code></pre>

Okay, this is the big one—here, the browsers use your signalling system to perform a two-phase pairing operation. First, in the **Session Description Protocol** (SDP) phase, they share information about audio, video, and data streams and their corresponding metadata; second, in the **Interactive Connectivity Establishment** (ICE) phase, they exchange IP addresses and port numbers and attempt to punch holes in each other&#8217;s firewalls.

WebRTC provides the `negotiationneeded` and `icecandidate` events to abstract over your signalling system. The `RTCPeerConnection` object fires these events whenever the browser needs to exchange SDP or ICE information (respectively), which can happen multiple times over the course of a WebRTC session as network conditions change.

Only the side that initiates the connection need be concerned with `negotiationneeded`. There&#8217;s a specific protocol both sides need to follow when responding to these events, or to messages from each other—it&#8217;s best to let the code speak for itself.

<pre class="wp-block-code"><code>let dataChannel = rtc.createDataChannel("data", { negotiated: true, id: 0 });
dataChannel.addEventListener("open", (event) => { ... });</code></pre>

Finally, set up your media and data streams. (For data channels, you can get away with a `negotiated` opening, which means the stream is pre-programmed on both ends and doesn&#8217;t require another handshake.) Wait for any `open` events to be fired.

You&#8217;re all done!