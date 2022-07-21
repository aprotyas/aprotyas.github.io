---
title: "C++: iterating a `std::tuple`"
date: 2022-07-20
permalink: /posts/2022/07/cpp-iterating-tuple
excerpt: "Warning: functional programming inside.<br>"
collection: posts
tags:
  - c++
  - functional programming
  - template programming
  - tuple
---

{% include base_path %}
{% include toc %}

## What is `std::tuple`? Where does it fit?

[`std::tuple`](https://en.cppreference.com/w/cpp/utility/tuple) is a nifty class template representing a fixed-size collection of heterogenous values.
They're a generalization of [`std::pair`](https://en.cppreference.com/w/cpp/utility/pair) and generally  behave like anonymized structs.
If for nothing else but readability reasons, you're almost always better off preferring the latter, but that doesn't make tuples completely useless.
Beside a ton of uses in generic code, tuples can be an easy way to return multiple values without particularly useful ordering semantics, combine heterogenous data sets from parallel executions with [`std::tuple_cat`](https://en.cppreference.com/w/cpp/utility/tuple/tuple_cat) (not uncommon in ML workflows!),  emulate the [`zip()`](https://docs.python.org/3.3/library/functions.html#zip) facility from Python (using structured bindings), and perform lexicographical comparisons (see below).

~~~ cpp
#include <tuple>

struct Foo {
  int bar;
  float baz;
  char qaz;

  bool operator<(const Foo& o) const {
    // bar < o.bar && baz < o.baz && qaz < o.qaz
    return std::tie(bar, baz, qaz) < std::tie(o.bar, o.baz, o.qaz);
  }
};
~~~

## Abusing `std::apply`

[`std::apply`](https://en.cppreference.com/w/cpp/utility/apply) invokes a [`Callable`](https://en.cppreference.com/w/cpp/named_req/Callable) object with elements of a tuple as its arguments, i.e. `apply(function, Tuple(a, b, c)) == function(a, b, c)`.
Cool, but what we really want is `function(x) for x ∈ [a, b, c]`.

Enter [parameter packs](https://en.cppreference.com/w/cpp/language/parameter_pack) and [fold expressions](https://en.cppreference.com/w/cpp/language/fold).

### Parameter pack

A (template) parameter pack is a template parameter with indefinite arity, i.e. one that accepts zero or more template arguments.
The same line of reasoning stands for function parameter packs, except in those cases the pack consists of function arguments whose types are deduced through [template argument deduction](https://en.cppreference.com/w/cpp/language/template_argument_deduction).

~~~ cpp
// parameter pack example
template< typename... Ts>
struct Tuple;

Tuple<int> t1;        // Ts == {int}
Tuple<int, float> t2; // Ts == {int, float}
~~~

### Fold expression

Formally, a [fold](https://en.wikipedia.org/wiki/Fold_(higher-order_function)) refers to a group of higher-order functions that construct an output by recombining the results of recursively processing the constituent sub-parts of a recursive data structure.
It is a concept borrowed from functional programming, and you may have heard of it referred as [reduce](https://docs.python.org/3.0/library/functools.html#functools.reduce), [accumulate](https://docs.python.org/3/library/itertools.html#itertools.accumulate) (link to a defined combination procedure), or [aggregate](https://dl.acm.org/doi/pdf/10.1145/318593.318660).

In C++, fold expressions let you reduce a parameter pack over a binary operator.
All combinations of unary/binary and left/right-sided fold ordering is valid.
Let's consider the unary right fold as a concrete example.

The unary right fold is expressed as `(pack op ...)`, where `pack` is "an expression that contains an *unexpanded* parameter pack and does not contain an operator with [precedence](https://en.cppreference.com/w/cpp/language/operator_precedence) lower than cast at the top level", and `op` is a binary operator (check [cppreference](https://en.cppreference.com/w/cpp/language/fold) for the list of allowed operators).
Upon expansion, this unary right fold represents `(E_{1} op (E_{2} op (... op (E_{N-1} op E_{N}))))`, where `N` is the number of elements in the parameter pack and `E_{k}` is the `k`-th element of said pack.

Phew, sorry about that wall of text.
Time for a hands-on example of fold expressions.

#### `any` - fold expression in practice

Here's a cool helper function to check that any of an arbitrary number of boolean flags is true.

~~~ cpp
template<typename ...Args> // parameter pack
bool any(Args... args) {
    return (args || ...);  // fold expression
}

{
  bool res = any(false, returns_true(), false, returns_false()); // CTAD!
  // res == true
}
~~~

Here, `<typename ...Args>` represents a type template parameter pack.
Notice the resemblance between `(args || ...)` and the general expression for a unary right fold `(pack op ...)`.
Within our `any` invocation, the unary right fold expands to `return false || (returns_true() || (false || returns_false()));`

## Back on track - `std::apply`

I alluded to the fact that parameter packs and fold expressions let us express `function(x) for x ∈ [a, b, c]` in lieu of `function(a, b, c)` with `std::apply`, but how so?

The first trick is in realizing that instead of spelling out the type list in a `std::tuple` instance, we could say "here's a variadic type list" representing all the types in this tuple object.
Remember what (out of many other things) a parameter pack can be?
Exactly, it can be a variadic type list.
The function signature and function call below illustrates this point.

~~~ cpp
template<typename ...TupleTypes>
void for_each(std::tuple<TupleTypes...> tuple);

{
  // Compiles in C++17
  for_each(std::make_tuple("a", 1010, true));
}
~~~

The second trick falls out of the fact that a parameter pack is in use.
We can use a fold expression to crunch through this parameter pack with a common (set of) expression(s).
These expressions, are *applied*, using `std::apply`!
Concretely:

~~~ cpp
template<typename ...TupleTypes>
void for_each(std::tuple<TupleTypes...> tuple) {
  // std::apply(CallableObject, Arguments)
  // CallableObject folds the parameter pack representing tuple's type list (elems)
  std::apply(
    [](auto tuple_elem)
    {
      (do_something(tuple_elem), ...);
    },
    tuple
  );
}
~~~

And there you have it ㋡
Time for a simple example summing up everything seen so far.

## Print all elements of a tuple

The following snippet should be simple enough to follow along now!
Here, I will define a `for_each` function that accepts any callable object and invokes said object with every element of a tuple.

~~~ cpp
template<typename ...TupleTypes, typename Callable>
void for_each(const std::tuple<TupleTypes...>& tuple, Callable func)
{
  std::apply(
    [func](const auto& tuple_elem)
    {
      (func(tuple_elem), ...);
    },
    tuple
  );
}

{
  for_each(
    std::make_tuple(1010, false, "name", 0.4),
    [](const auto& tuple_elem) { std::cout << tuple_elem << '\n'; }
  );
}

/*
  1010
  0
  name
  0.4
*/
~~~

Note that this snippet is not perfect.
The `Callable` template argument is not checked for callability - something `std::is_invocable` can handle.
Next, it restricts you to the unary right fold expression with a `,` operator.
Maybe instead you'd like to add elements of your tuple after some transformation?
My saving grace is that this should serve as a reasonable backbone for you to tinker with... check the next section for more inspiration.

## Where can you go with this?

In my opinion, people who want "duck typing" semantics in C++ can take this the whole length.
Imagine you want to transform all items in a heterogenous collection, which is a lot of words for `map(Func, Iterable)` from Python land.
No one would stop you from `for_each(l-value ref to Tuple, Transform)`, right?
Tack on some type traits or your own concepts to replicate `Protocol` types from Python land and really there is no looking back anymore...
