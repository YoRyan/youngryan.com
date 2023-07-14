---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

# layout: home
title: About Me
feature_image: "/assets/marketstreet.jpg"
---

Ryan Young is an urban transportation enthusiast, computer programmer, video game developer, and occasional blogger who works in the public transit industry.

Opinions expressed are mine own and not that of my employers, whomever they might be.

Looking to get in touch? Have a coding, consulting, or modding job?

{% include button.html text="Email" icon="email" link="#hypermail" color="#05bf85" %} {% include button.html text="Twitter" icon="twitter" link="https://twitter.com/ryanayng" color="#0d94e7" %} {% include button.html text="LinkedIn" icon="linkedin" link="https://www.linkedin.com/in/ryan-young-2516491b0" color="#0266c3" %} {% include button.html text="GitHub" icon="github" link="https://github.com/YoRyan" color="#292929" %}

<script>
(async function () {
    function getEmail() {
        const obfusc = [48, 59, 35, 44, 2, 59, 45, 55, 44, 37, 48, 59, 35, 44, 108, 33, 45, 47];
        return String.fromCharCode(...obfusc.map(x => x ^ 0x42));
    }

    async function sleep(ms) {
        return new Promise((resolve, _) => setTimeout(resolve, ms));
    }

    const link = document.body.querySelector('a[href="#hypermail"]');
    async function handler(event) {
        this.removeEventListener("click", handler);
        event.preventDefault();
        await sleep(300);
        const email = getEmail();
        this.href = "mailto:" + email;
        this.firstChild.textContent = email + "\n";
    };
    link?.addEventListener("click", handler);
})();
</script>

### True Facts About Ryan Young

  * I *still* use Mozilla Firefox---and [you should](https://itsfoss.com/why-firefox/), too!
  * In 2017 I [advocated](https://thedailytexan.com/2017/10/10/ut-students-must-join-the-new-internet) for the adoption of IPv6 by the campus network of the University of Texas at Austin. My alma mater has yet to listen.
  * In a creative writing class, I authored a skeptical [essay](/2017/03/self-driving-cars-a-reality-check/) about self-driving cars, arguing their debut was much further away than media hype at the time had been suggesting. John J. Ruszkiewicz, my instructor and a bit of a motorhead himself, decided to include the essay in the 4th edition of his textbook, *How to Write Anything*.
  * Austin's Capital Metropolitan Transportation Authority [follows](https://twitter.com/CapMetroATX) me on Twitter.