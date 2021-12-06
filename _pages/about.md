---
permalink: /
title: "About me"
excerpt: "About me"
author_profile: true
redirect_from:
  - /about/
  - /about.html
---

Hi, my name is Abrar.

I was born and raised in Dhaka, Bangladesh. I currently reside in Rochester, NY, USA.

I am broadly interested in robotics and autonomous systems.
This interest ranges throughout the 'robotics' stack: from motion planning and state estimation to manipulation and human-robot interaction.

As an undergraduate student at the University of Rochester, I worked as a research assistant at the [Robotics and Artificial Intelligence Laboratory](http://www2.ece.rochester.edu/projects/rail/) (RAIL) - where I investigated the use of probabilistic graphical models to infer distributions of parametrized controllers for underactuated robots.

In summer 2021, I was a software engineering intern at [Open Robotics](https://www.openrobotics.org/).
At Open Robotics, I've been working on general development of [Robotics Operating System](https://en.wikipedia.org/wiki/Robot_Operating_System) (ROS), which is an open source software framework enabling robotics applications, deployment, and research.
I still contribute to general ROS 2 development - it's a great community to work with!

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
