---
title: "Prepending text to a file. How?"
date: 2021-03-22
permalink: /posts/2021/03/prepending-to-a-file
excerpt: "`cat` + `>`? `awk`? `sed`? `vim`? Just don't? Such choice, much wow.<br>"
collection: posts
tags:
  - unix
  - file i/o
---

{% include base_path %}
{% include toc %}

## What? and why?

Click the drop-down menu to enjoy my anecdote about file prepending.

<details>
<summary>Story time!</summary>
<br>
Imagine being me, a teaching assistant for an Intro to Programming
class. It's mid-March, I have 3 things overdue since yesterday, and I
<b>need</b> to finish grading the latest problem set. (I'm pictured below)  

<br>
<br>

<img src="/images/posts/prepend/procrastination.jpeg"
     alt="Procrastinating Abrar"
     style="width:400px;height:300px;"/>

<br>
<br>
So, like any rational person, I spend an evening creating an auto-grader
pipeline - and feel very smart because I made students return some integer
from a function, which I can easily test against :-)  

<br>
<br>

The last step in this grading pipeline is to add an annotated feedback
template, showing what the student got right (and wrong). Back in the
heydays, Abrar had enough energy to. But Abrar has aged... queue the need
to prepend content from one file to another!

<br>
<br>
<small>[If you think this is a ridiculous reason to go down this rabbit
hole, then you are right. But this is a <strong>blog</strong>, and I'm trying
to be <strong>funny</strong>.]</small>
</details>

## How?

### Input redirection and `cat`

### `awk`

### `sed`

### `vim`

## Some useful examples

