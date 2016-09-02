"""
Boyer-Moore string search implementation.

Ported from [search.go](https://golang.org/src/strings/search.go). Most
of the documentation and comments are verbatim copy from go code.
"""

actor Main
  let _env: Env

  new create(env: Env) =>
    _env = env
    let f = StringFinder("CG")
    let text = "CGCGTCGAATGGACTAGTACAGTACAGATCTGGACTCT"
    let res = f.find(text)
    env.out.write(res.string() + "\n")
    for result in f.find_all(text) do
      env.out.write(result.string() + "\n")
    end


primitive _LongestCommonSuffix
  fun apply(a: String box, b: String box): USize =>
    var idx: USize = 0
    let lena = a.size()
    let lenb = b.size()
    while (idx < lena) and (idx < lenb) do
      if try a(lena-1-idx) != b(lenb-1-idx) else false end then
        break
      end
      idx = idx + 1
    end
    idx


class StringFinderIterator is Iterator[ISize]
  let _finder: StringFinder val
  let _text: String box
  var _next: ISize
  let _shift: ISize

  new create(text: String box, finder: StringFinder val, shift: ISize) =>
    _finder = finder
    _text = text
    _shift = shift
    _next = -shift

  fun ref has_next(): Bool =>
    _next = _finder.find(_text, (_next + _shift).usize())
    if _next == -1 then false else true end

  fun next(): ISize => _next


class val StringFinder
  """
  StringFinder efficiently finds strings in a source text. It's implemented
  using the Boyer-Moore string search algorithm:
  http://en.wikipedia.org/wiki/Boyer-Moore_string_search_algorithm
  http://www.cs.utexas.edu/~moore/publications/fstrpos.pdf (note: this aged
  document uses 1-based indexing)

  ```pony
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

  """
  let pattern: String val
  let _size: USize

	// _badCharSkip[b] contains the distance between the last byte of pattern
	// and the rightmost occurrence of b in pattern. If b is not in pattern,
	// badCharSkip[b] is len(pattern).
	//
	// Whenever a mismatch is found with byte b in the text, we can safely
	// shift the matching frame at least badCharSkip[b] until the next time
	// the matching char could be in alignment.
  let _badCharSkip: Array[USize]

	// _goodSuffixSkip[i] defines how far we can shift the matching frame given
	// that the suffix pattern[i+1:] matches, but the byte pattern[i] does
	// not. There are two cases to consider:
	//
	// 1. The matched suffix occurs elsewhere in pattern (with a different
	// byte preceding it that we might possibly match). In this case, we can
	// shift the matching frame to align with the next suffix chunk. For
	// example, the pattern "mississi" has the suffix "issi" next occurring
	// (in right-to-left order) at index 1, so goodSuffixSkip[3] ==
	// shift+len(suffix) == 3+4 == 7.
	//
	// 2. If the matched suffix does not occur elsewhere in pattern, then the
	// matching frame may share part of its prefix with the end of the
	// matching suffix. In this case, goodSuffixSkip[i] will contain how far
	// to shift the frame to align this portion of the prefix to the
	// suffix. For example, in the pattern "abcxxxabc", when the first
	// mismatch from the back is found to be in position 3, the matching
	// suffix "xxabc" is not found elsewhere in the pattern. However, its
	// rightmost "abc" (at position 6) is a prefix of the whole pattern, so
	// goodSuffixSkip[3] == shift+len(suffix) == 6+5 == 11.
  let _goodSuffixSkip: Array[USize]

  new val create(pattern': String) =>
    pattern = pattern'  
    _size = pattern.size()

    // index of the last byte in the pattern
    let last = _size - 1

    // Build bad character table.
    // Bytes not in the pattern can skip one pattern's length.
    _badCharSkip = Array[USize].init(_size, 255)
    var idx: USize= 0
    // The loop condition is < instead of <= so that the last byte does not
    // have a zero distance to itself. Finding this byte out of place implies
    // that it is not in the last position.
    while idx < last do
      try _badCharSkip.update(pattern(idx).usize(), last-idx) end
      idx = idx + 1
    end

    // Build good suffix table.
    _goodSuffixSkip = Array[USize].init(0, _size)
    // First pass: set each value to the next index which starts a prefix of
    // pattern.
    var lastPrefix = last
    idx = last
    while true do
      if pattern.at(pattern.substring((idx+1).isize())) then
        lastPrefix = idx + 1
      end
      // lastPrefix is the shift, and (last-idx) is suffix.size()
      try _goodSuffixSkip.update(idx.usize(), lastPrefix + (last - idx)) end
      if idx == 0 then break end
      idx = idx - 1
    end

    // Second pass: find repeats of pattern's suffix starting from the front.
    idx  = 0 
    while idx < last do
      let lenSuffix = _LongestCommonSuffix(pattern, pattern.substring(1,(idx+1).isize()))
      if try pattern(idx - lenSuffix) != pattern(last-lenSuffix) else false end  then
        // (last-idx) is the shift, and lenSuffix is suffix.size().
        try _goodSuffixSkip.update((last-lenSuffix).usize(), lenSuffix + (last-idx)) end
      end
      idx = idx + 1
    end

  fun val find(text: String box, start_pos: USize = 0): ISize=>
    """
    return the index of the first occurence of the pattern starting at
    ``start_pos``. -1 if not found.
    """
    var idx = (_size - 1) + start_pos
    let tsize = text.size()
    while idx < tsize do
      var jdx= (_size - 1).usize()
      while try (jdx >= 0) and (text(idx) == pattern(jdx)) else false end do
        if jdx == 0 then
          return idx.isize()
        end
        idx = idx - 1
        jdx = jdx - 1
      end
      idx  = idx + try _badCharSkip(text(idx).usize()).max(_goodSuffixSkip(jdx)) else 1 end
    end 
    -1

  fun val find_all(text: String, overlap: Bool=false): StringFinderIterator =>
    StringFinderIterator(text, this, if overlap then 1 else (_size).isize()end)
