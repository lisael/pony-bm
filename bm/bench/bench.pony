use "ponybench"
use "bm"
// Currently (Aug 31) there's a segfault in the builtin `no match` bench
// The error doesn't show with ponyc -d :/
// The bug is in llvm, compile ponyc with
// make LLVM_CONFIG=llvm-config-3.6 LLVM_LINK=llvm-link-3.6 LLVM_OPT=opt-3.6
// sudo make install

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
    compare(needle, long_haystack, "one letter")

    needle = "aaaaaaaaaaaaaaa"
    haystack = "aaaaaaaaaaaaaaaaaab"
    compare(needle, haystack, "long needle")

  fun compare(needle: String, haystack: String, group: String) =>
    // benchmark Fib with different inputs
    bench[ISize](group + ": builtin", BuiltinFinder(needle, haystack))
    bench[ISize](group + ": boyer-moore", Finder(needle, haystack))

