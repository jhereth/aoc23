import std/enumerate
import std/math
import std/sequtils
import std/sets
import std/strformat
import std/strutils
import std/tables
import std/typetraits

let x = """
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
"""

type Dir = enum
    L, U, R, D

type Grid = object
    width, height : int
    map : seq[string]

proc parseInput(s: string) : Grid =
    result.map = s.splitLines.filterIt(it.len > 0)
    result.height = result.map.len
    result.width = result.map[0].len
    for line in result.map:
        assert line.len == result.width

let x1p = x.parseInput

type Cand = ((int, int), Dir)

proc `+`(pos: (int, int), dir: Dir) : (int, int) =
        result[0] = pos[0] + {U: -1, D: 1}.toTable.getOrDefault(dir, 0)
        result[1] = pos[1] + {L: -1, R: 1}.toTable.getOrDefault(dir, 0)

proc flip(dir: Dir) : Dir =  # /
    {L: D, R: U, D: L, U: R}.toTable[dir] 

proc flop(dir: Dir) : Dir =  # \
    {L: U, R: D, D: R, U: L}.toTable[dir] 

for d in @[L, R, D, U]:
    echo (2,3) + d

proc shine(grid: Grid, start: Cand = ((0,0), R)) : int =
    var next : seq[Cand] = @[start]
    var visited : seq[Cand] = @[] 
    # echo &"Size: {grid.height} rows, {grid.width} columns"
    proc get(grid: Grid, pos: (int, int)) : char =
        grid.map[pos[0]][pos[1]]
    proc addIfValid(grid: Grid, cand: Cand) =
        let i = cand[0][0]
        let j = cand[0][1]
        if (
            (0 <= i) and
            ( i < grid.height) and
            (0 <= j) and
            (j < grid.width)
        ):
            next.add(cand)
    while next.len > 0:
        var current = next.pop
        if current in visited: continue
        visited.add(current)
        let pos = current[0]
        let dir = current[1]
        let c = grid.get(pos)
        case c:
            of '.':
                # echo "dot"
                grid.addIfValid(((pos + dir), dir))
            of '/':
                # echo "mirror /"
                let newDir = dir.flip
                grid.addIfValid(((pos + newDir), newDir))
            of '\\':
                # echo "mirror \\"
                let newDir = dir.flop
                grid.addIfValid(((pos + newDir), newDir))
            of '-':
                # echo "split -"
                case dir:
                    of D, U:
                        grid.addIfValid(((pos + L), L))
                        grid.addIfValid(((pos + R), R))
                    of R, L:
                        grid.addIfValid(((pos + dir), dir))
            of '|':
                case dir:
                    of L, R:
                        grid.addIfValid(((pos + U), U))
                        grid.addIfValid(((pos + D), D))
                    of D, U:
                        grid.addIfValid(((pos + dir), dir))
            else:
                raise newException(ValueError, fmt"Found unknown char {c} at {current}")
        # echo current
        # echo next
        # echo &"{visited.len:>5}" & ".".repeat(next.len)
    # echo visited
    return visited.mapIt(it[0]).deduplicate.len


# echo x1p.shine
let file = readFile("input.txt")
let fp = file.parseInput
# assert fp.shine == 7434

proc multiShine(grid: Grid, start: Cand = ((0,0), R)) : int =
    var bestStart : Cand = ((int.low, int.low), R)
    var bestScore = int.low
    for row in 0 ..< grid.height:
        echo &"row {row}/{grid.height} ({bestScore})"
        var pos = (row, 0)
        var score = shine(grid, start=(pos, R))
        if score > bestScore:
            bestStart = (pos, R)
            bestScore = score
            # echo bestScore, bestStart
        pos = (row, grid.width - 1)
        score = shine(grid, start=(pos, L))
        if score > bestScore:
            bestStart = (pos, L)
            bestScore = score
            # echo bestScore, bestStart
    for col in 0 ..< grid.width:
        echo &"col {col}/{grid.width} ({bestScore})"
        var pos = (0, col)
        var score = shine(grid, start=(pos, D))
        if score > bestScore:
            bestStart = (pos, D)
            bestScore = score
            # echo bestScore, bestStart
        pos = (grid.height - 1, col)
        score = shine(grid, start=(pos, U))
        if score > bestScore:
            bestStart = (pos, U)
            bestScore = score
            # echo bestScore, bestStart
    return bestScore

echo x1p.multiShine
echo fp.multiShine