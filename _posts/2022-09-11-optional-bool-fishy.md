---
title: "C++: `optional<bool>` is a code smell"
date: 2022-09-11
permalink: /posts/2022/09/optional-bool-smelly
excerpt: "And how you can make it less smelly<br>"
collection: posts
tags:
  - c++
  - short article
  - software design
---

{% include base_path %}
{% include toc %}

## What is an optional type?

An optional type -- known more broadly as option type or maybe type -- is a polymorphic type that represents encapsulation of an optional value.
It's used to represent a type we care about (`Foo`) as either "Nothing" or "Some `Foo`" value.

## Where is the problem?

The problem lies in the semantics around optional values.
In C++, [`std::optional<T>`](https://en.cppreference.com/w/cpp/utility/optional) values are often conflated for their truthiness through their [boolean conversion operator](https://en.cppreference.com/w/cpp/utility/optional/operator_bool).
That is, it's quite natural to check that an optional value has a value type much like you'd check if an expression is true.

Guess what else demonstrates truthiness?
That's right, good old booleans.

So what happens when you have two layers of truthiness? Confusion around what `if(optional_boolean_value)` is supposed to mean.
Should it mean what `if(boolean_value)` means? Or should it mean what `if(optional_value)` means?

Below is a toy example where, depending on how you read the logic, you may end up losing all your money to a Nigerian prince.

~~~ cpp
#include <optional>

{
  auto maybe_flag { std::optional<bool>{false} };
  if (maybe_flag) // flag == false, money == safe?
  {
    send_all_money_to_nigerian_prince();
  }
  else
  {
    try_harder_scammer();
  }
}
~~~

For clarity, in this context `maybe_flag` evaluates to true since the optional variable `maybe_flag` is indeed populated with a boolean.
This might go against what some might infer from a cursory glance of that snippet.

## What is the solution?

As always, there is no one-size-fits-all solution, but:

### Anarchy? Delete boolean conversion
Since `std::optional` can act truthy because of its `operator bool()` method, why don't we just kill it?
Okay, let's be a bit kinder and just kill it for the `bool` case.

Reader exercise: write a type predicate `is_truthy` and use it to delete `operator bool()` for all truthy types, i.e. types that can be converted to boolean. Email me if you need help. 🙂

~~~ cpp
#include <optional>

template<>
std::optional<bool>::operator bool() const = delete;

{
  if (std::optional<bool>{false}) // compiler screams at you
  {
    send_all_money_to_nigerian_prince();
  }
}
~~~

This approach forces you to explicitly spell out your intentions - either in the form of `foo.has_value()` when you want to see whether the optional value is empty, or in the form of `foo.value` when you want to see what the underlying boolean flag says.

### Black and white... or gray? Tri-state bools

One of the most useful courses I attended in college was the philosophy department's "Introduction to Logic".
My professor ingrained in me the idea that even in logical formalism, there is space for grayness.

In three-valued logic, there are three truth values indicating true, false, and some indeterminate third value.
Can you see how this third value can be used to represent some unknown value?
That is, it does the job of a `std::optional`?
The key here is that the boolean conversion should represent any intermediate value as false, and not true.

[Boost.Tribool](https://www.boost.org/doc/libs/1_80_0/doc/html/tribool.html) is one such library that implements a 3-state boolean representation.
It's provisions are simple - a single class [`boost::logic::tribool`](https://www.boost.org/doc/libs/1_80_0/doc/html/boost/logic/tribool.html), along with operator overloading to implement the 3-state boolean logic.

Here's what the previous example would look like with a tristate boolean -- notice how you're less likely to lose all your money this time...

~~~cpp
#include <boost/logic/tribool.hpp>

{
  boost::logic::tribool maybe_flag {false};
  if (maybe_flag) // evaluates to false, as expected!
  {
    send_all_money_to_nigerian_prince();
  }
  else
  {
    try_harder_scammer();
  }
}
~~~

### Linting saves the day - Custom clang-tidy checks

> But muh STL-only project! I won't pull in Boost dependencies!! 😡

I won't debate against this surprisingly popular opinion, but if you really want to stick to the standard library's optional type, consider at least linting against the problematic behavior!

From Clang 14 onwards, clang-tidy ships with [support for external plugin checks](https://releases.llvm.org/14.0.0/tools/clang/tools/extra/docs/ReleaseNotes.html#improvements-to-clang-tidy).
This empowers users like you and me to write custom checks that can easily plug into the preprocesser level analysis ([PPCallbacks](https://clang.llvm.org/doxygen/classclang_1_1PPCallbacks.html)) or on the AST level analysis ([AST Matchers](https://clang.llvm.org/doxygen/classclang_1_1PPCallbacks.html)), and what better way to exercise this power than to add a clang-tidy check for calls to `std::optional<bool>::operator bool()`?

Hang tightly for a future blog post where I'll try to implement such a check, and if you really can't wait, do it yourself with this guide - [Writing a clang-tidy check](https://releases.llvm.org/14.0.0/tools/clang/tools/extra/docs/clang-tidy/Contributing.html#writing-a-clang-tidy-check).