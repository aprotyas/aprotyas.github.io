---
title: "macOS: Change `vim` background based on system theme"
date: 2021-10-10
permalink: /posts/2021/10/macos-change-vim-background
excerpt: "How? `Defaults`, `VimScript`, and everything nice...<br>"
collection: posts
tags:
  - macos
  - vim
  - dark mode
  - vimscript
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


Now, picture me, super happy with my midnight dark mode session, when I open `vim` to have the screen glare at me like 5000K surgical room lights.
NOT FUN.
After some strained eyes and an hour wasted, I've found a solution that lets `vim` automagically adapt to system theme changes!

## How?

### TLDR

Stick the following snippet in your `vim` configuration file.

~~~ vim
let theme = system('defaults read -g AppleInterfaceStyle')
if theme =~ 'Dark'
    set background = dark
else
    set background = light
endif
~~~

### Long answer

There are three ingredients in the secret sauce!

#### How do I know what "mode" the system is in?
Welcome `defaults`! `defaults` is a command line utility provided in macOS that allows users to read, write, and delete Mac OS X user defaults from a command-line shell.
Part of the user defaults we can read here is the `AppleInterfaceStyle`, which is a key to what style the user's interface is in - holding the value `"Dark"` when the system is in dark mode, and not existing when the system is in light mode.

The following command provides the information we need.
Note the `-g` flag to indicate the global domain.
~~~ bash
defaults read -g AppleInterfaceStyle
~~~

Note: the above key only exists when macOS is in dark mode, but you will see shortly why this isn't a problem.

#### How do I provide `vim` this knowledge?
Welcome `vimscript` - the subset of `vim`'s ex-commands which supply features that allow scripting.
These "script"s find a convenient home in one's `vim` configuration (`vimrc`) file.
The salient feature here is the `system()` function, which allows execution of a command string parameter in the background shell, returning the output of said command as a string.

Put two and two together, and the following line of `vimscript` provides access to the system mode (stored in the `theme` variable) in your `vim` configuration.
~~~ vim
let theme = system('defaults read -g AppleInterfaceStyle')
~~~

Note: Remember when I said the above key only exists when the system is in dark mode?
Well, that means the variable `theme` is only populated _some_ times.
We're in luck though, because our decision space is binary - and we know `theme` is either `"Dark"` or nothing!

#### What behavior is modified based on this knowledge?
Welcome `vimscript` again - but now with conditional statements!
At this point, we really just have to condition some configuration steps around the `theme` variable from the previous step.
The `background` option in `vim` - *waves hand* - lets users indicate whether the system has a `"light"` or a `"dark"` background.
Setting this option to a specific value also adjusts the color groups in use for the background.
As you can imagine, light yellow syntax highlighting may not be the most appealing on a light background... but I digress.

At this point, we can conditionally set the value of `background` as below.
~~~ vim
" is 'Dark' in `theme`?
if theme =~ 'Dark'
    set background = dark
else
    set background = light
endif
~~~

Note: this behavior is best paired with a colorscheme that defines different color groups for different backgrounds, but this is not a headache if you're using the colorschemes shipped by `vim`.

Put all of the above together, and you get the TLDR from earlier!

---

#### Room for improvement?
At this point, this is no longer a half-hour hack, but the one glaring room for improvement is handling the "light mode" case more gracefully.
What if the decision space was not binary, and we had to condition `vim`'s behavior on light/dark/X instead?
Ignoring the output (or the lack thereof) of the `defaults` invocation in light mode would then not be feasible.
Having said that, I think I've found a reasonable solution... **exit status**!

Remember how `UserInterfaceStyle` is only a valid key if the system is in dark mode?
Similarly, the `defaults` command exits successfully in dark mode only.
As such, we can safely ignore the actual string returned by the command in lieu of its exit status, made possible with:

~~~ bash
defaults read -g AppleInterfaceStyle >/dev/null 2>&1
~~~

We can go a step further and use `vim`'s internal `shell_error` variable, which is a flag that gets triggered when a shell command returns an error - as would happen here if macOS were not currently in dark mode. Let's see what this would look like as a snippet in a `vim` configuration file.

~~~ vim
" s: indicates script variable
" need to call this to populate `shell_error`
let s:theme = system('defaults read -g AppleInterfaceStyle >/dev/null 2>&1')

" v: indicates vim variable
" if shell_error is set, macOS must have been in light mode
if v:shell_error
    set background = light
else
    set background = dark
endif
~~~

Finally, and I will leave this as an exercise for the reader, the above logic could be encapsulated in a function that's called on a timer once the to-be-edited file is loaded into `vim`'s buffer.
This would prevent user's from noticing the (~20ms) delay introduced by this logic since it would not pause the act of loading the file for setting the background.
