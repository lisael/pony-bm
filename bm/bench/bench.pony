use "ponybench"
use "bm"
// Currently (Aug 31) there's a segfault in the builtin `no match` bench
// The error doesn't show with ponyc -d :/ so I couldn't narrow the LoC in
// ponybench. The segfault probably comes from builtin. I'm currently
// trying to reproduce with a simpler code (w/o ponybench)

class BuiltinFinder
  let _n: String
  let _h: String
  new val create(needle: String, haystack: String) =>
    _n = needle
    _h = haystack

  fun box apply(): ISize => try _h.find(_n) else -1 end

class Finder
  let _f: StringFinder
  let _h: String
  new val create(needle:String, haystack: String) =>
    _f = StringFinder(needle)
    _h = haystack

  fun box apply(): ISize => _f.find(_h)

actor Main
  let bench: PonyBench
  new create(env: Env) =>
    bench = PonyBench(env)

    // BM is far better at this one, strcmp performs needle.size()*haystack.size() comparisions,
    // whereas BN performs only h.size()/n.size()
    var needle = "aaaaaaaaaaaaaaab"
    var long_haystack = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" +
    "aaaaaaaaaaaaaaaaaaaab"
    compare(needle, long_haystack, "long")

    // no match
    needle = "ccc"
    var haystack = "aaaaaaaaaaaaaaaaaab"
    compare(needle, haystack, "no match")

    // strcmp best cases
    needle = "b"
    compare(needle, long_haystack, "2")

    needle = "aaaaaaaaaaaaaaa"
    haystack = "aaaaaaaaaaaaaaaaaab"
    compare(needle, haystack, "3")

  fun compare(needle: String, haystack: String, group: String) =>
    // benchmark Fib with different inputs
    bench[ISize](group + ": builtin", BuiltinFinder(needle, haystack))
    bench[ISize](group + ": boyer-moore", Finder(needle, haystack))

