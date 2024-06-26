---
permalink: /
title: "About me"
excerpt: "About me"
author_profile: true
redirect_from:
  - /about/
  - /about.html
---

Hi, my name is Abrar. `aprotyas` is my online identity.

I was born and raised in Dhaka, Bangladesh. I currently reside in the Bay Area, CA working on the [WebKit](http://webkit.org) browser engine at Apple.

In a previous life, I used to write developer tools for roboticists at [Argo AI](https://en.wikipedia.org/wiki/Argo_AI). Before that, I studied at the University of Rochester and investigated motion planning for underactuated robots

When away from the computer, I enjoy petting cats, playing football, and exploring food. Send me food recs and I'll send you a cat pic in return.

[//]: # (Put a most-recent blog posts archive here, if you ever write one LOL)

## Blog?

I might occasionally write "blog" posts to (a) document an experience or
(b) document a quick hack. The latter will be for my own reference, but please
feel free to suggest better alternatives if you ever stumble upon these posts.
{: .notice}  

{% if site.posts.size > 3 %}
  Some recent posts:  
{% endif %}

{% assign post_limit = 3 %}
{% for post in site.posts limit:post_limit %}
  {% include archive-single.html %}
{% else %}
No blog posts yet, but stay tuned!
{% endfor %}  

{% if site.posts.size > 3 %}
  Check out more posts [here](year-archive)!
{% endif %}
