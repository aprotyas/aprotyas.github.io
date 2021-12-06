---
title: "C++: non-negative signed integral?"
date: 2021-10-10
permalink: /posts/2021/10/cpp-nonnegative-integral
excerpt: "Type traits to the rescue!<br>"
collection: posts
tags:
  - c++
  - template programming
  - type traits
---

{% include base_path %}
{% include toc %}

In this article, I'll summarize my first experience playing with type traits in C++.
Note that as my first experience, I've decided not to dig too deep into cv-qualifications, being able to modify references of my wrapper, and all the sugar you'd get with a real wrapper.
What I have done is write a skeleton of an observer that shows me enough about templates and type traits for it to be a meaningful exercise -- and I hope this simple example helps someone else grasp this concept too!

## Awkward interfaces

Have you ever come across an interface that does a lazy job at constraining its inputs?
Tell me, why does this API - with the comment, of course - exist?

~~~ cpp
/* argument must be non-zero */
void foo(int64_t bar);
~~~

After many ways to rationalize this, I just swallowed the better pill and decided to materialize the non-negativity comment!
With that, we come to today's goal: **greedy non-negativity invariance enforcement for signed integral types**.

## Welcome type traits

Type traits is a ~fantastic rabbit-hole~ templated interface that lets you express ideas/constraints around types, and even modify the properties of types, all in compile time!
These templates are defined in the [`<type_traits>`](https://en.cppreference.com/w/cpp/header/type_traits) header.

A particularly useful metafunction in that header is [`std::enable_if`](https://en.cppreference.com/w/cpp/types/enable_if).
Think of it as a compile-time switch for templates.
This switch lets us tap into an idiomatic C++ rule - "Substitution Failure Is Not An Error"[(SFINAE)](http://en.wikipedia.org/wiki/Substitution_failure_is_not_an_error).
Explaining SFINAE would take 5 of these blog posts, so the wiki redirection will have to do for now.
`std::enable_if` lets us define a `typedef` to a given type if its template argument evaluates to a logically true value.
In other words, if we specify constraints as part of `std::enable_if`'s template arguments, we will cause substitution failures (hence omitting a template instantiation) if said constraints are not satisfied. Now, about constraints...

For this situation, I want to represent two constraints:

- The number must be of **integral** type.
  - Integral is a big net, but notable residents are `bool`, `char`, `charX_t`, `short`, `int`, `long`, and all of their signed and cv-qualified varieties... that's a mouthful.
  - Really, I just need to avoid floating point types here.
  - [`std::is_integral`](https://en.cppreference.com/w/cpp/types/is_integral) is my new best friend for this.
- The number must be of **signed** type.
  - Why? Well, this also motivates why the interface accepted a signed integral type! Because unsigned integers give you zero information, maximum chaos. Imagine accidentally producing a negative number only to feed that into an unsigned container? No warnings, just overflow and vibes...
  - [`std::is_signed`](https://en.cppreference.com/w/cpp/types/is_signed) is my best friend for this.

Just like that, we have our building blocks to conditionally (`std::enable_if`) build a wrapper around signed (`std::is_signed`), integral (`std::is_integral`) types.
In C++, the template argument that represents these constraints is:

~~~cpp
template<
  class T,
  typename = std::enable_if<std::is_integral<T>::value && std::is_signed<T>::value>::type
>
~~~

Here's what happened above - we have a template type `T`.
`std::is_integral<T>::value` is `true` if `T` is an integral type - and likewise for `std::is_signed`.
Looking at the signature `std::enable_if<bool B, class T = void>`, what happens is that if expression `B` evaluates to `true`, the templated class `enable_if` will have a public typedef `type` equal to `T`.
If expression `B` evaluates to `false`, there is no such typedef.
Finally, `typename = ...` just indicates the presence of an optional template parameter with no name and a default value.
As you can guess, if that default value is nothing - there is a compiler error, which is exactly what happens if we have either an unsigned type, or a non-integral type, or both!

C++14 introduced some type aliases that make for succint expression of constraints like this, namely `std::enable_if_t`, `std::is_integral_v`, and `std::is_signed_v`, where the `a_x` just represents `a::x`.
Rewriting with these aliases, we get:

~~~cpp
template<
  class T,
  typename = std::enable_if_t<std::is_integral_v<T> && std::is_signed_v<T>>
>
~~~

## What's in a wrapper?

Finally, the wrapper around our signed, integral type is very short.
Its only job is to greedily - at assignment/construction time - check that its not wrapping a negative number.
This can be achieved as follows:

~~~cpp
class non_negative {
public:
  // What does a default construction mean here?
  non_negative() = delete;

  non_negative(T _number) {
    // Negative number check!
    if (_number < static_cast<T>(0)) {
      throw std::runtime_error("Please enter non-negative number.");
    }
    number = _number;
  }

private:
  T number;
}
~~~

The last piece of this puzzle is to make this wrapper transparent to the user or the interfaces consuming it.
Remember the simple duck test? If it walks like a duck and it talks like a duck...
Right!
As long as this wrapper can be implicitly converted to the type it represents, we have the duck.
This is what the implicit (templated) conversion operator looks like:

~~~cpp
inline operator T() const { return static_cast<T>(number); }
~~~

## Ready for takeoff

Combining all the snippets above, this is the wrapper I have:

~~~cpp
template<
  class T,
  typename = std::enable_if_t<std::is_integral_v<T> && std::is_signed_v<T>>
>
class non_negative {
public:
  // What does a default construction mean here?
  non_negative() = delete;

  non_negative(T _number) {
    if (_number < static_cast<T>(0)) {
      // Negative number check!
      throw std::runtime_error("Please enter non-negative number.");
    }
    number = _number;
  }

  // Implicit conversion to underlying integral type
  inline operator T() const { return static_cast<T>(number); }

private:
  T number;
};
~~~

In about 22 lines of code, I learned about type traits, SFINAE, and got to think about better interface designs -- particularly when the interface has semantically convoluted constraints!
**Not a bad use of 22 lines.**

[Here's the link to my wrapper on a Github gist](https://gist.github.com/aprotyas/02803a4ade50059285ec8f7badbf2edd) if you'd like to investigate further.
Check out my [Github profile (@aprotyas)](https://github.com/aprotyas) for more of my coding -- no, it's not playing around with type traits all day!
