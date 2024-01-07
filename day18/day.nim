import std/algorithm
import std/colors
import std/enumerate
import std/heapqueue
import std/math
import std/os
import std/sequtils
import std/sets
import std/strformat
import std/strutils
import std/tables
import std/terminal
import std/typetraits

type Dir = enum
    L, U, R, D

const QDir = {L, U, R, D}

proc `-`(dir: Dir) : Dir =
    {L: R, R: L, D: U, U: D}.toTable[dir]

proc flip(dir: Dir) : Dir =  # /
    {L: D, R: U, D: L, U: R}.toTable[dir] 

proc flop(dir: Dir) : Dir =  # \
    {L: U, R: D, D: R, U: L}.toTable[dir] 

type Pos = (int, int)

proc posCmp(lhs, rhs: Pos) : int =
    if lhs[0] == rhs[0]:
        return cmp(lhs[1], rhs[1])
    cmp(lhs[0], rhs[0])

proc `+`(lhs, rhs: Pos) : Pos =
    result[0] = lhs[0] + rhs[0]
    result[1] = lhs[1] + rhs[1]

proc `*`(factor: int, dir: Dir) : Pos =
        result[0] = {U: -factor, D: factor}.toTable.getOrDefault(dir, 0)
        result[1] = {L: -factor, R: factor}.toTable.getOrDefault(dir, 0)

proc `+`(pos: Pos, dir: Dir) : (int, int) =
    result = pos + (1 * dir)

proc `+=`(self: var Pos, dir: Dir)  =
    self = self + (1 * dir)


# for A* see Day 17

let x1 = """
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
"""

proc parseInput1(s: string) : seq[(int, Dir)] =
    let splitted = s.splitLines.filterIt(it.len > 0)
    for line in splitted:
        let splitLine = line.splitWhitespace
        let dirStr = splitLine[0]
        let dir = {"R": R, "D": D, "U": U, "L": L}.toTable[dirStr]
        let count = splitLine[1].parseInt
        result.add((count, dir))

echo x1.parseInput1


proc inner(segs: seq[(int, Dir)]) : (int, int) =
    var current : Pos = (0, 0)
    var corners : seq[Pos]
    var edges : seq[(Pos, Dir, int, int)]
    for i, seg in enumerate(segs):
        corners.add(current)
        let count = seg[0]
        let dir = seg[1]
        let prevDir = segs[euclMod(i - 1, segs.len)][1]
        let nextDir = segs[euclMod(i + 1, segs.len)][1]
        # echo &"{i}: {prevDir} -> {dir} -> {nextDir} ({seg})"
        let next = current + (count * dir)
        let crosses = if prevDir == nextDir: 1 else: 0
        # echo (current, next, crosses)
        case dir:
            of R, D:
                edges.add((current, dir, count, crosses))
            of L, U:
                edges.add((current + (count * dir), -dir, count, crosses))
        current = next
    assert current == (0, 0)
    # echo &"We have {corners.len} corners"
    let edgeCount = edges.mapIt(it[2]).sum
    # echo &"The edge is {edgeCount} long"

    var iSlices = corners.mapIt(it[0]).sorted.deduplicate
    var jSlices = corners.mapIt(it[1]).sorted.deduplicate
    # echo &"iSlices={iSlices}"
    # echo &"jSlices={jSlices}"
    var innerCount = edgeCount

    proc isInner(pos: Pos) : bool =
        # counting crossings from (-1, pos[1]) to pos.
        # If odd, this is an inner point
        # echo &"Processing {pos}"
        var crossings: int  
        for edge in edges:
            let start = edge[0]
            if start[0] > pos[0]: continue  # edge is below pos
            let dir = edge[1]
            let length = edge[2]
            # echo &"edge {edge} ends at {start + (length * dir)}"
            case dir:
                of R:
                    # not relevant
                    # (excluding start and end which belong to vertical edge)
                    if (pos[1] <= start[1]) or (start[1] + length <= pos[1]) : continue
                    if start[0] == pos[0]: return false  # pos on edge
                    # echo &"Crossing {edge}"
                    crossings += 1
                of D:
                    if start[1] != pos[1]: continue  # vertical edge in different column
                    if pos[0] <= start[0] + length: return false  # pos is on edge
                    # echo &"Possibly crossing {edge}"
                    crossings += edge[3]
                else:
                    raise newException(ValueError, &"Encountered {dir} in edge {edge}")
        # echo &"Crossing count: {crossings}"
        crossings mod 2 == 1

    for i1 in iSlices:
        for j1 in jSlices:
            if isInner((i1, j1)):
                # echo &"Adding Corner ({i1}, {j1}) as inner"
                innerCount += 1
            # else:
                # echo &"Corner ({i1}, {j1}) is not inner (outer or edge)"
    # echo &"Corners processed, inner count={innerCount}"
    # Going through all vertical segments
    for idx, i1 in enumerate(iSlices[0..<iSlices.high]):
        let i2 = iSlices[idx + 1]
        if i1 + 1 == i2: continue # segment of two corners, no inner points
        for j1 in jSlices:
            if isInner((i1 + 1, j1)):
                innerCount += i2 - i1 - 1
            # else:
                # echo &"Segment {i1 + 1} .. {i2 - 1}  x {j1}) is not inner"
    # echo &"Vertical segments processed, inner count={innerCount}"
    # Going through all horizontal segments
    for i1 in iSlices:
        for jdx, j1 in enumerate(jSlices[0..<jSlices.high]):
            let j2 = jSlices[jdx + 1]
            if j1 + 1 == j2: continue # segment of two corners, no inner points
            if isInner((i1, j1 + 1)):
                innerCount += j2 - j1 - 1
            # else:
                # echo &"Segment {i1} x {j1 + 1}..{j2 - 1}) is not inner"
    # echo &"Horizontal segments processed, inner count={innerCount}"

    for idx, i1 in enumerate(iSlices[0..<iSlices.high]):
        let i2 = iSlices[idx + 1]
        if i2 == i1 + 1: continue  # no inner points
        # Going through all rectangles in the iSlices x jSlices grid (excluding corners/edges)
        for jdx, j1 in enumerate(jSlices[0..<jSlices.high]):
            let j2 = jSlices[jdx + 1]
            if j2 == j1 + 1: continue  # no inner points
            # echo &"Processing rectangle {i1 + 1}..{i2 - 1} x {j1 + 1}..{j2 - 1}"
            if isInner((i1 + 1, j1 + 1)):
                # if (i1+1, j1+1) is an inner point, _all_ points in the rectangle 
                # (i1 + 1 .. i2 - 1) x (j1 +1 .. j2 - 1) are inner
                # echo &"Adding rectangle {i1 + 1}..{i2 - 1} x {j1 + 1}..{j2 - 1}"
                innerCount += (i2 - i1 - 1) * (j2 - j1 - 1)

    (edgeCount, innerCount)


proc test1() =
    let x1r = x1.parseInput1.inner
    echo x1r
    assert x1r[0] == 38
    assert x1r[1] == 62

test1()

let file = readFile("input.txt")

proc final1() =
    let fr = file.parseInput1.inner
    assert fr == (3680, 39194)
    echo fr

final1()

proc parseInput2(s: string) : seq[(int, Dir)] =
    let splitted = s.splitLines.filterIt(it.len > 0)
    for line in splitted:
        let splitLine = line.split("#")
        let dirStr = splitLine[1][^2..^2]
        let dir = {"0": R, "1": D, "3": U, "2": L}.toTable[dirStr]
        let countStr = splitLine[1][0..^3]
        let count = countStr.parseHexInt
        result.add((count, dir))

proc test2() =
    let x1r2 = x1.parseInput2.inner
    assert x1r2[1] == 952408144115

test2()

proc final2() =
    let fr2 = file.parseInput2.inner
    assert fr2[1] == 78242031808225
    echo fr2

final2()

# for i in 0..100:
#   stdout.styledWriteLine(fgRed, "0% ", fgWhite, '#'.repeat i, if i > 50: fgGreen else: fgYellow, "\t", $i , "%")
#   sleep 42
#   cursorUp 1
#   eraseLine()

# let color = parseColor("#ffaa53")
# let color2 = parseColor("#00aa53")
# let fgCol = ansiForegroundColorCode(color)
# let bgCol = ansiBackgroundColorCode(color2)
# stdout.resetAttributes()
# stdout.styledWriteLine(bgCol, "Foo Foo")
# stdout.resetAttributes()
# # echo "|" & $bgCol & ";" & $bgCol & "  | Hallo "
# stdout.resetAttributes()

# echo "0x70c71".parseHexInt