---
permalink: /
title: "About me"
excerpt: "About me"
author_profile: true
redirect_from:
  - /about/
  - /about.html
---

Hello, I am a senior undergraduate student studying Electrical and Computer Engineering
at the University of Rochester. I am broadly interested in robotics and
autonomous systems. This interest ranges throughout the 'robotics' stack: from
motion planning and state estimation to manipulation and human-robot interaction.
I am currently a research assistant at the
[Robotics and Artificial Intelligence Laboratory](http://www2.ece.rochester.edu/projects/rail/)
(RAIL) at the University of Rochester, looking at the use of
probabilistic graphical models to infer distributions of parametrized
controllers for underactuated robots.

[//]: # (Put a most-recent blog posts archive here, if you ever write one LOL)

## Blog?

I might occasionally write "blog" posts to (a) document an experience or
(b) document a quick hack. The latter will be for my own reference, but please
feel free to suggest better alternatives if you ever stumble upon these posts.
{: .notice}  

{% if site.posts.size > 2 %}
  Some recent posts:  
{% endif %}

{% assign post_limit = 2 %}
{% for post in site.posts limit:post_limit %}
  {% include archive-single.html %}
{% else %}
No blog posts yet, but stay tuned!
{% endfor %}  

{% if site.posts.size > 2 %}
  Check out more posts [here](year-archive)!
{% endif %}
