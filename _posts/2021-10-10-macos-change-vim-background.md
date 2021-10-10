---
title: "macOS: Change `vim` background based on system theme"
date: 2021-10-10
permalink: /posts/2021/10/macos-change-vim-background
excerpt: "How? `AppleScript`, `VimScript`, and everything nice...<br>"
collection: posts
tags:
  - macos
  - vim
  - dark mode
  - vimscript
  - applescript
---

{% include base_path %}
{% include toc %}

In this article, I will document how I was able to **automatically configure the `vim` text editor's colorscheme, conditioned on macOS's default system "theme"**, i.e. light mode or dark mode.
The assumption going into the article is that a reader knows what the `vim` text editor is and has their own configuration file - namely a `vimrc` file.

## System themes? macOS? What, why?

macOS versions 10.14 and later provide built-in support for a system-wide light-on-dark color scheme, lovingly known as dark mode!
If you don't already know, dark mode renders light-color text, icons, and interfaces on a dark background.
If you do already know, you also know that dark mode has taken over the world, not without good reason; providing users' eyes a less strenuous time, especially at night.
It goes without saying that "light mode" is simply the opposite of dark mode, more inline with conventional user interface designs.

<img src="/images/posts/macos-vim-theme/lightvsdark.png"
     alt="Light mode vs dark mode"
     style="width:400px;height:180px;"/>

:exclamation: Unpopular opinion alert :exclamation: - Yet, light mode is better than dark mode.
No further questions taken.
Having said that, the best solution here is to opt for an automatically enforced light/dark mode routine.
Enjoy the colors you want to enjoy without giving up on your eyes!
And luckily, macOS supports exactly that - accessible through `System Preferences > General > Appearance`.

<br style="line-height:2px">

Now, picture me, super happy with my midnight dark mode session, when I open `vim` to have the screen glare at me like 5000K surgical room lights.
NOT FUN.
After some strained eyes and an hour wasted, I've found a solution that lets `vim` automagically adapt to system theme changes!

## How?
