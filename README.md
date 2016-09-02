# Pony-bm

Pony-bm is a pure-pony implementation of the [Boyer-Moore](
http://en.wikipedia.org/wiki/Boyer-Moore_string_search_algorithm) string search
algorithm.

## Usage

```pony
use "bm"

actor Main
  new create(env: Env) =>
    _env = env
    let f = StringFinder("CG")
    let text = "CGCGTCGAATGGACTAGTACAGTACAGATCTGGACTCT"
    env.out.write(f.find(text).string() + "\n") // prints 0
    env.out.write(f.find(text, 1).string() + "\n") // prints 2
    for result in f.find_all(text) do
      env.out.write(result.string() + "\n") prints 0,2,5
    end
```

## Performances

TL;DR:

```
make bench
```

It may be faster than the builtin [String](http://www.ponylang.org/ponyc/builtin-String/).find()` method.

Boyer-Moore algorithm computes statisics on the search pattern that speeds up
the search operation by skipping byte comparisions. This computation has a
cost, so the real speedup is achieved if the `StringFinder` is reused. The
form of the pattern and of the searched text is important, too.

To decide if bm fits your needs, [make benches](https://github.com/lisael/pony-bm/blob/master/bm/bench/bench.pony).
