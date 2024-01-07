import std/enumerate
import std/math
import std/sequtils
import std/strformat
import std/strutils
import std/tables

let x1 = """
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#....
"""
type Coord = tuple[x,y: int]

proc parseInput(s: string) : (seq[Coord], seq[int], seq[int]) =
    var universes : seq[Coord]
    let split = s.splitLines.filterIt(it.len > 0)
    let width = split[0].len
    let height = split.len
    var colCount = newSeq[int](width)
    var rowCount = newSeq[int](height)
    for i, row in enumerate(split):
        for j, c in enumerate(row):
            if c == '#':
                rowcount[i] += 1
                colcount[j] += 1
                universes.add((i, j))
    return (universes, rowCount, colCount)



let x1p = parseInput(x1)
assert x1p == (@[(x: 0, y: 3), (x: 1, y: 7), (x: 2, y: 0), (x: 4, y: 6), (x: 5, y: 1), (x: 6, y: 9), (x: 8, y: 7), (x: 9, y: 0), (x: 9, y: 4)], @[1, 1, 1, 0, 1, 1, 1, 0, 1, 2], @[2, 1, 0, 1, 1, 0, 1, 2, 0, 1])
# echo x1p
# echo x1p[0].len

proc blowUpUniverse(input: (seq[Coord], seq[int], seq[int]), factor : int = 2) : seq[Coord] =
    let observed = input[0]
    let rowCounts = input[1]
    let colCounts = input[2]
    var rowTransform, colTransform: seq[int]
    var shift = 0
    for i, c in enumerate(rowCounts):
        rowTransform.add(i + shift)
        if c == 0: shift += factor - 1
    shift = 0
    for j, c in enumerate(colCounts):
        colTransform.add(j + shift)
        if c == 0: shift += factor - 1
    for univ in observed:
        result.add((rowTransform[univ.x], colTransform[univ.y]))
    # echo rowTransform
    # echo colTransform

let x1pb = blowUpUniverse(x1p)
assert x1pb == @[(x: 0, y: 4), (x: 1, y: 9), (x: 2, y: 0), (x: 5, y: 8), (x: 6, y: 1), (x: 7, y: 12), (x: 10, y: 9), (x: 11, y: 0), (x: 11, y: 5)]

proc manhattan(lhs, rhs: Coord) : int =
    abs(lhs.x - rhs.x) + abs(lhs.y - rhs.y)

let expected = @[9, 15, 17, 5]
for i, (f,s) in enumerate(@[(4,8), (0, 6), (2, 5), (7, 8)]):
    let distance = manhattan(x1pb[f],x1pb[s])
    # echo fmt"{f} - {s}: {distance}"
    assert distance == expected[i]

proc part1(galaxies: seq[Coord]) : int =
    echo fmt"Working with {galaxies.len} galaxies"
    for f in 0 .. galaxies.len - 1:
        for s in (f + 1) .. (galaxies.len - 1) :
            let distance = manhattan(galaxies[f],galaxies[s])
            # echo fmt"{f} - {s}: {distance}"
            result += distance

assert part1(x1pb) == 374

let file = readFile("input.txt")
let fpb = file.parseInput.blowUpUniverse
echo fpb.part1
assert fpb.part1 == 9418609

assert  x1p.blowUpUniverse(10).part1 == 1030
assert  x1p.blowUpUniverse(100).part1 == 8410
echo x1p.blowUpUniverse(1000_000).part1 # 82000210
echo file.parseInput.blowUpUniverse(1000_000).part1 # 593821230983

        