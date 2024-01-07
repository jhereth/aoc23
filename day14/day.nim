import std/algorithm
import std/enumerate
import std/math
import std/sequtils
import std/strformat
import std/strutils
import std/tables
import std/typetraits

let x1 = """
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
"""

let x1tilt = """
OOOO.#.O..
OO..#....#
OO..O##..O
O..#.OO...
........#.
..#....#.#
..O..#.O.O
..O.......
#....###..
#....#....
"""

proc parseInput(s: string) : seq[string]=
    let split = s.splitLines
    var cols = newSeq[string](split[0].len)
    for line in split:
        for i, c in enumerate(line):
            cols[i].add(c)
    return cols.mapIt(it.join)

proc sortCol(col: string) : string =
    # echo col
    var tilted: seq[string]
    let parts = col.split("#")
    for part in parts:
        let os = part.count('O')
        tilted.add("O".repeat(os) & ".".repeat(part.len - os))
    # echo tilted.join("#")
    return tilted.join("#")

proc calcLoad(col: string) : int =
    for i, c in enumerate(col):
        if c == 'O':
            result += col.len - i




for (s, expected) in zip(x1.parseInput, x1tilt.parseInput):
    assert s.sortCol == expected

let col = ".O...#O..O"
echo col
echo col.sortCol

echo x1.parseInput
assert x1.parseInput.map(sortCol).map(calcLoad).sum == 136

let file = readFile("input.txt")
assert file.parseInput.map(sortCol).map(calcLoad).sum == 106990


proc draw(dish: seq[string]) =
    for row in 0 .. dish[0].high:
        for col in dish:
            stdout.write(col[row])
        stdout.write("\n")

proc turn(dish: seq[string]) : seq[string] =
    for i in countdown(dish[0].high, 0):
        result.add(dish.mapIt(it[i]).join)

proc cycle(dish: seq[string]) : seq[string] =
    result = dish
    for i in 0 .. 3:
        result = result.map(sortCol)
        result = result.turn

proc multiCycle(dish:seq[string], cycles : int = 1_000_000_000) : seq[string] =
    result = dish
    var findAgain = newTable[seq[string], int]()
    # echo findAgain.type.name
    for i in 0 ..< cycles:
        if result in findAgain:
            let previous = findAgain[result]
            let period = i - previous
            let remaining = (cycles - previous) mod period
            echo fmt"Found dish again after {i} cycles. Previous was {previous}, i.e. period=={period}. {remaining} cycles to go."
            result = result.multiCycle(cycles=remaining)
            echo fmt"Load is {result.map(calcLoad).sum}"
            return result
        findAgain[result] = i
        result = result.cycle
        if i mod 1000_000 == 0:
            result.draw
            echo i

assert x1.parseInput.multiCycle.map(calcLoad).sum == 64
assert file.parseInput.multiCycle.map(calcLoad).sum == 100531

