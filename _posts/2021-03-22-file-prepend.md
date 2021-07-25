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
Prepending one file (or just a string of content) to another file,
while not fairly common, is an operation that usually needs to be
done in batches. As such, it's useful to know some tricks to automate
this process. Unlike the append operator (`>>`) in UNIX, there is
no unique prepend operator, meaning a straightforward solution can
be hard to come by.

<br>

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
from a function, which I can easily test against. :-)

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

<br>
<br>
<i>Note:</i> This was at a time before I knew testing frameworks are a thing...
</details>

## How?

### Input redirection and `cat`
The trick to using `cat` is to remember that `cat` can "conCATenate" multiple
files. As such, `cat` can be used to concatenate the string to prepend and
the file to prepend in. The string to prepend is piped into the standard input
(`-`), following which is some temporary file moves.

```bash
echo 'STRING' | cat - FILE.txt > temp && mv temp FILE.txt
```

Alternatively, if the content to be prepended resides in another file, the
initial `echo` command can be skipped altogether and the standard input stream
to `cat` can be replaced with the file containing the text to prepend.

### `sed`
`sed` can be used to perform basic text transformations on an input stream,
hence fitting the bill for this task. `sed` can be configured to perform
in-place text transformations (with the `-i` flag). Furthermore, a substitution
directive for the first character of the first line may be provided to perform
the necessary prepending - since all edits will occur in-place. For example:

```bash
sed -i.old '1s;^;STRING;' FILE.txt
```

<i>Warning:</i> This Does NOT work if the input file is empty (0 bytes). Moreover, `sed`
both misinterprets newlines as special pattern matching characters and has the
possibility of not being cross-platform at least between GNU and BSD `sed`.

### `vim`
Vim can be opened in Ex mode (`-e`) which allows entry of `Ex` commands,
typically useful for batch processing applications. The command required
can be provided from the CLI using the `-c` flag, which causes execution
of a command after loading the first file provided.
```bash
vim -e -c '0r [file-with-content]|x [file-to-prepend-to]
```
