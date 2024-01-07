import std/algorithm
import std/enumerate
import std/math
import std/sequtils
import std/strformat
import std/strutils

let file = readFile("input.txt")
echo file.splitLines.mapIt(it.len).max

proc parseInput(s: string) : seq[tuple[rows, cols: seq[string]]] =
    let splitted = s.splitLines
    var rows, cols: seq[string]
    var width = -1
    var startNew = true
    for line in splitted:
        # echo fmt"line=|{line}|"
        if line.len == 0:
            if rows.len > 0:
                assert cols.len > 0
                # echo rows.len
                result.add((rows, cols))
                rows = @[]
                startNew = true
            continue
        if startNew:
            width = line.len
            cols = newSeq[string](width)
            startNew = false
        rows.add(line)
        for i, c in enumerate(line):
            cols[i].add(c)
        # echo fmt"result={result}, rows={rows}, cols = {cols}"


let x1 = """
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
"""

let x1p = x1.parseInput
let fp = file.parseInput

proc areAlmostEqual(lhs, rhs: seq[string], threshold : int = 0) : bool =
    zip(lhs.join, rhs.join).mapIt(if it[0] != it[1]: 1 else: 0).sum == threshold

proc findMirrors(ls: seq[string], threshold: int = 0) : seq[int] =
    for i in ls.low .. ls.high - 1:
        let width = min(i + 1, ls.len - i - 1)
        # echo fmt"i={i}, width={width}, ls={ls} ({ls.len})"
        if areAlmostEqual(ls[i - width + 1 .. i], ls[i + 1 .. i + width].reversed, threshold):
            # echo fmt"Found mirror at {i}"
            result.add(i)

# for r in fp:
#     if (r.cols.findMirrors.len + r.rows.findMirrors.len) > 1:
#         echo fmt"Found multiple mirrors in {r}"

# echo x1p[0].cols.findMirrors
# echo x1p[1].rows.findMirrors

proc mirrorValue(rows, cols: seq[string], threshold: int = 0) : int =
    var mirrors = cols.findMirrors(threshold)
    if mirrors.len > 0:
        return mirrors[0] + 1
    mirrors = rows.findMirrors(threshold)
    if mirrors.len > 0:
        return 100 * (mirrors[0] + 1)

assert x1p.mapIt(mirrorValue(it.rows, it.cols)).sum == 405

assert fp.mapIt(mirrorValue(it.rows, it.cols)).sum == 29130 

assert x1p.mapIt(mirrorValue(it.rows, it.cols, 1)).sum == 400

assert fp.mapIt(mirrorValue(it.rows, it.cols, 1)).sum == 33438