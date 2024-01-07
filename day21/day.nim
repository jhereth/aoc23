import std/algorithm
import std/enumerate
import std/heapqueue
import std/math
import std/sequtils
import std/sets
import std/strformat
import std/strutils
import std/tables
import std/typetraits

type Dir = enum
    L, U, R, D

const QDir = {L, U, R, D}

proc flip(dir: Dir): Dir = # /
    {L: D, R: U, D: L, U: R}.toTable[dir]

proc flop(dir: Dir): Dir = # \
    {L: U, R: D, D: R, U: L}.toTable[dir]

proc `-`(dir: Dir): Dir =
    {L: R, R: L, D: U, U: D}.toTable[dir]

type Pos = (int, int)

proc `*`(factor: int, dir: Dir): Pos =
    result[0] = {U: -factor, D: factor}.toTable.getOrDefault(dir, 0)
    result[1] = {L: -factor, R: factor}.toTable.getOrDefault(dir, 0)

proc `+`(lhs, rhs: Pos): Pos =
    result[0] = lhs[0] + rhs[0]
    result[1] = lhs[1] + rhs[1]

proc `+`(pos: Pos, dir: Dir): (int, int) =
    result = pos + (1 * dir)

proc `+=`(self: var Pos, dir: Dir) =
    self = self + (1 * dir)

# for A* see Day 17
# for counts of inner points see Day 18

type GridRange = range[0 .. (131 * 131)] # size of final grid
type GridSet = set[GridRange]

type Grid = object
    width, height: int
    start: Pos
    map: seq[string]
    adj: Table[int, GridSet]

proc get(grid: Grid, pos: Pos): char =
    let (i, j) = pos
    if ((i < 0) or (grid.height <= i) or (j < 0) or (grid.width <=
            j)): return '#'
    return grid.map[i][j]

proc toInt(grid: Grid, pos: Pos): GridRange =
    result = pos[0] * grid.width + pos[1]
    assert (0 <= result) and (result <= 131*131), &"out of range for {pos}"

proc toPos(grid: Grid, n: int): Pos =
    (n.div(grid.width), n.euclMod(grid.width))

proc draw(grid: Grid) =
    for i in -1..grid.height:
        for j in -1..grid.width:
            stdout.write(grid.get((i, j)))
            if ((0 <= i) and (i < grid.height) and (0 <= j) and (j < grid.width)):
                assert (i, j) == grid.toPos(grid.toInt((i, j))), &"failed for {i}, {j}"
        stdout.write("\n")

let x1 = """
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
"""
proc parseInput(s: string): Grid =
    result.map = s.splitLines.filterIt(it.len > 0)
    result.height = result.map.len
    result.width = result.map[0].len
    for i, line in enumerate(result.map):
        assert line.len == result.width
        if "S" in line:
            let j = line.find("S")
            result.start = (i, j)
            var line = line
            line[j] = '.'
            result.map[i] = line
    for i in 0 ..< result.height:
        for j in 0 ..< result.width:
            var neighbours: GridSet
            for d in QDir:
                let cand = (i, j) + d
                if result.get(cand) == '.':
                    let candSet: GridSet = {result.toInt(cand)}
                    neighbours = neighbours + candSet
            result.adj[result.toInt((i, j))] = neighbours
    result.draw()


proc step(
    grid: Grid,
    steps: int = 64,
    frontier: GridSet = {grid.toInt(grid.start)},
    current: GridSet = {grid.toInt(grid.start)},
    prev: GridSet = {},
): GridSet =
    if steps == 0: return current
    var next: GridSet
    for f in frontier:
        next = next + grid.adj[f]
    next = next - prev
    return grid.step(
        steps = steps - 1,
        frontier = next,
        current = prev + next,
        prev = current,
    )



assert x1.parseInput.step(steps=6).len == 16



let file = readFile("input.txt")
echo file.parseInput.step().len
