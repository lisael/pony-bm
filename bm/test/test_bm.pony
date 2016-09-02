use "ponytest"
use "bm"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestFind)
    test(_TestFindAll)

class iso _TestFind is UnitTest
  let needle: String = "CG"
  let haystack: String = "aCGtCGagtc"
                        //0123456789

  fun name():String => "Find"

  fun apply(h: TestHelper) =>
    let f = StringFinder(needle)
    // find the first occurence
    var idx = f.find(haystack)
    h.assert_eq[ISize](idx, 1)
    // do we find the occurence if we start the search at its very index?
    idx = f.find(haystack, 1)
    h.assert_eq[ISize](idx, 1)
    // find the second occurence
    idx = f.find(haystack, 2)
    h.assert_eq[ISize](idx, 4)
    let f' = StringFinder("not here")
    h.assert_eq[ISize](f'.find(haystack), -1)
    // nothing bad happen if the needle is larger than the haystack
    idx = f.find("a")
    h.assert_eq[ISize](idx, -1)


class iso _TestFindAll is UnitTest
  let needle: String = "CG"
  let haystack: String = "aCGtCGagtc"
                       // 0123456789

  fun name():String => "FindAll"

  fun apply(h: TestHelper) =>
    let f = StringFinder(needle)
    let fa = f.find_all(haystack)
    h.assert_eq[Bool](fa.has_next(), true)
    h.assert_eq[ISize](fa.next(), 1)
    h.assert_eq[Bool](fa.has_next(), true)
    h.assert_eq[ISize](fa.next(), 4)
    h.assert_eq[Bool](fa.has_next(), false)
    // findall should not overlap by default
    let hs = "aaaa"
           // 0123
    let f' = StringFinder("aa")
    let fa' = f'.find_all(hs)
    fa'.has_next()
    h.assert_eq[ISize](fa'.next(), 0)
    fa'.has_next()
    h.assert_eq[ISize](fa'.next(), 2)
    h.assert_eq[Bool](fa'.has_next(), false)
    // but it can
    let fa'' = f'.find_all(hs, true)
    fa''.has_next()
    h.assert_eq[ISize](fa''.next(), 0)
    fa''.has_next()
    h.assert_eq[ISize](fa''.next(), 1)
    fa''.has_next()
    h.assert_eq[ISize](fa''.next(), 2)
    h.assert_eq[Bool](fa''.has_next(), false)
