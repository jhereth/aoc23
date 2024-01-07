import std/algorithm
import std/enumerate
# import std/enumutils
import std/sequtils
import std/strformat
import std/strutils
import std/tables
import typetraits

type qDir = enum
    qdL, qdU, qdR, qdD

proc `-`(rhs: qDir): qDir =
    case rhs:
        of qdL:
            return qdR
        of qdU:
            return qdD
        of qdR:
            return qdL
        of qdD:
            return qdU

type Coord = tuple[x,y: int]

proc `+=`(self: var Coord, rhs: Coord) =
    self.x += rhs.x
    self.y += rhs.y

proc `+`(lhs, rhs: Coord) : Coord =
    (lhs.x + rhs.x, lhs.y + rhs.y)


const QDirDelta : Table[qDir, Coord]= {
    qdL: (-1, 0),
    qdU: (0, -1),
    qdR: (1, 0),
    qdD: (0, 1),
    }.toTable

# echo QDirDelta.type.name

# let x = {
#     qdL: @[(-1, 0), (2,0)],
#     }.toTable
# echo x.type.name

let x1 = """
-L|F7
7S-7|
L|7||
-L-J|
L|-JF
"""

type Pipe = enum
    I, m, L, J, V, F, N, S 

const CharPipe : Table[char, Pipe] = {
    '|': I,
    '-': m,
    'L': L,
    'J': J,
    '7': V,
    'F': F,
    '.': N,
    'S': S,
}.toTable

const CornerChars = @['L', 'J', '7', 'F']

const PipeConn : Table[Pipe, seq[qDir]] = {
    I: @[qdU, qdD], # |
    m: @[qdR, qdL], # -
    L: @[qdU, qdR],
    J: @[qdU, qdL],
    V: @[qdD, qdL], # 7
    F: @[qdD, qdR],
    N: @[], # .
    S: @[qdU, qdR, qdD, qdL],
}.toTable


type Map = object
    width: int
    height: int
    entries: Table[Coord, Pipe]

proc parseInput*(s: string) : (Coord, Map) =
    var start : Coord
    let splitted = s.splitLines.filterIt(it.len > 0)
    var map : Map
    map.height = splitted.len
    map.width = splitted[0].len
    for y, line in enumerate(splitted):
        echo &"|{line}|"
        assert line.len == map.width
        let spos = line.find("S")
        if spos > 0:
            start = (spos, y)
        for x, c in enumerate(line):
            map.entries[(x,y)] = CharPipe[c]
    return (start, map)



proc canGo(start: Coord, map: Map, direction: qDir) : bool =
    let next = start + QDirDelta[direction]
    var nextVal: Pipe
    try:
        nextVal = map.entries[next]
    except:
        # lookup not successful, has left map
        return false
    let nextConns = PipeConn[nextVal]
    if not (-direction in nextConns):
        # can't go to next coord
        return false
    return true

proc explore(start: Coord, map: Map) : seq[Coord] =
    # echo "explore"
    # echo start
    var halfs = 0
    while halfs < 2:
        for d in PipeConn[map.entries[start]]:
            # echo "d-loop"
            # echo d
            var current = start
            result.add(current)
            # echo "current: " & $current
            var d = d
            while true:  # will be exited by return or break
                # echo "inner loop"
                if canGo(current, map, d):
                    current += QDirDelta[d]
                else:
                    # echo "nogo"
                    return @[]
                result.add(current)
                let nextVal = map.entries[current]
                if nextVal == S:
                    # echo "found S"
                    halfs += 1
                    break
                # echo "current (next)"
                # echo current
                # echo "nextVal"
                # echo nextVal
                let nextConns = PipeConn[nextVal]
                for nextD in nextConns:
                    # echo "next cand"
                    # echo nextD
                    if nextD == -d:
                        # echo "we came from " & $(-d)
                        continue
                    # echo "using " & $nextD
                    d = nextD
                    break
    result = result.deduplicate
                
                


proc findLoopLength(x: (Coord, Map)) : int =
    let start = x[0]
    let map = x[1]
    for d in qDir.items:
        # echo "trying " & $d
        if canGo(start, map, d):
            # echo "exploring " & $d
            let pipe = explore(start + QDirDelta[d], map)
            if pipe.len > 0:
                # echo pipe
                return pipe.len

let x2 = """
-L|F7
7S-7|
L|7||
-L-J|
L|-JF
"""


proc test1() =
    var x1p = parseInput(x1)
    # echo x1p
    assert findLoopLength(x1p) == 8
    let x2p = parseInput(x2)
    assert findLoopLength(x2p) == 8


# test1()

proc final1() =
    let file = readFile("input.txt")
    let fp = parseInput(file)
    assert findLoopLength(fp) == 14132


proc fixS(start: Coord, map: Map, pipe: seq[Coord]) : Map =
    result = map
    let canGos = qDir.toSeq.filterIt(canGo(start, map, it))
    result.entries[start]  = PipeConn.keys.toSeq.filterIt(canGos.sorted == PipeConn[it].sorted)[0]

proc findOuterCoord(height, width: int, pipe: seq[Coord]) : (Coord, qDir) =
    let x = min(pipe.mapIt(it[0]))
    let minxs = pipe.filterIt(it[0]==x)
    let y = min(minxs.mapIt(it[1]))
    if x > 0:
        if not ((x - 1, y) in pipe):
            return ((x - 1, y), qdR)
    if y > 0:
        if not ((x, y - 1) in pipe):
            return ((x, y - 1), qdD)
    # edge case all outer nodes are part of the pipe not handled
    assert false
    
proc followTheLoop(outerStart: (Coord, qDir), pipe: seq[Coord], map: Map) : seq[Coord] =
    let startPipe = outerStart[0] + QDirDelta[outerStart[1]]
    var dir = -outerStart[1]  # changing perspective
    var current = startPipe
    var nextPipe : Coord = (low(int), low(int))
    var moved = false
    while (nextPipe != startPipe) or (not moved):
        # echo fmt"{$current} on {$map.entries[current]}, looking {$dir}. Waiting for {$startPipe}. ({$result.len}" #: {$result})"        
        case dir:
            of qdD:
                case map.entries[current]:
                    of L, m, F:
                        result.add(current + QDirDelta[dir])
                        nextPipe = current + QDirDelta[qdR]
                        moved = true
                        # dir = qdD # unchanged
                    of J:
                        result.add(current + QDirDelta[qdD]) 
                        result.add(current + QDirDelta[qdD] + QDirDelta[qdR]) 
                        result.add(current + QDirDelta[qdR]) 
                        nextPipe = current
                        dir = qdR
                    of V:
                        result.add(current + QDirDelta[qdD]) 
                        result.add(current + QDirDelta[qdD] + QDirDelta[qdL]) 
                        result.add(current + QDirDelta[qdL]) 
                        nextPipe = current
                        dir = qdL
                    else:
                        raise newException(ValueError, fmt"Got {$map.entries[current]} while looking {$dir}")
            of qdL:
                case map.entries[current]:
                    of V, I, F:
                        result.add(current + QDirDelta[dir])
                        nextPipe = current + QDirDelta[qdD]
                        moved = true
                        # dir = qdL # unchanged
                    of J:
                        result.add(current + QDirDelta[qdL])
                        result.add(current + QDirDelta[qdL] + QDirDelta[qdU])
                        result.add(current + QDirDelta[qdU])
                        nextPipe = current
                        dir = qdU
                    of L:
                        result.add(current + QDirDelta[qdL])
                        result.add(current + QDirDelta[qdL] + QDirDelta[qdD])
                        result.add(current + QDirDelta[qdD])
                        nextPipe = current
                        dir = qdD
                    else:
                        raise newException(ValueError, fmt"Got {$map.entries[current]} while looking {$dir}")
            of qdU:
                case map.entries[current]:
                    of m, J, V:
                        result.add(current + QDirDelta[dir])
                        nextPipe = current + QDirDelta[qdL]
                        moved = true
                        # dir = qdL # unchanged
                    of L:
                        result.add(current + QDirDelta[qdU])
                        result.add(current + QDirDelta[qdU] + QDirDelta[qdR])
                        result.add(current + QDirDelta[qdR])
                        nextPipe = current
                        dir = qdR
                    of F:
                        result.add(current + QDirDelta[qdU])
                        result.add(current + QDirDelta[qdU] + QDirDelta[qdL])
                        result.add(current + QDirDelta[qdL])
                        nextPipe = current
                        dir = qdL
                    else:
                        raise newException(ValueError, fmt"Got {$map.entries[current]} while looking {$dir}")
            of qdR:
                case map.entries[current]:
                    of J, I, L:
                        result.add(current + QDirDelta[dir])
                        nextPipe = current + QDirDelta[qdU]
                        moved = true
                        # dir = qdL # unchanged
                    of F:
                        result.add(current + QDirDelta[qdR])
                        result.add(current + QDirDelta[qdR] + QDirDelta[qdD])
                        result.add(current + QDirDelta[qdD])
                        nextPipe = current
                        dir = qdD
                    of V:
                        result.add(current + QDirDelta[qdR])
                        result.add(current + QDirDelta[qdR] + QDirDelta[qdU])
                        result.add(current + QDirDelta[qdU])
                        nextPipe = current
                        dir = qdU
                    else:
                        raise newException(ValueError, fmt"Got {$map.entries[current]} while looking {$dir}")
        current = nextPipe



                        

proc draw(pipe, outer, inner: seq[Coord], map: Map) =
    for y in 0 .. map.height - 1:
        for x in 0 .. map.width - 1:
            if (x, y) in pipe:
                stdout.write('P')
            elif (x, y) in outer:
                stdout.write('o')
            elif (x, y) in inner:
                stdout.write('.')
            else:
                stdout.write('?')
        stdout.write('\n')

proc findInner*(x: (Coord, Map)): int =
    let start = x[0]
    var map = x[1]
    var pipe : seq[Coord] 
    for d in qDir.items:
        # echo "trying " & $d
        if canGo(start, map, d):
            # echo "exploring " & $d
            pipe = explore(start + QDirDelta[d], map)
            if pipe.len > 0: break
    echo "Found pipe of length " & $pipe.len
    map = fixS(start, map, pipe)
    # echo "replaced S by " & $map.entries[start]
    let outerStart = findOuterCoord(map.height, map.width, pipe)
    # echo "Starting from " & $outerStart
    var outerCandidates = followTheLoop(outerStart, pipe, map)
    echo &"In current iteration: {outerCandidates.len} candidates remaining"
    # draw(pipe, outerCandidates, @[], map)

    outerCandidates = (
        outerCandidates
        .deduplicate
        .filterIt(not (it in pipe))
        .filterIt(it.x >= 0)
        .filterIt(it.x < map.width)
        .filterIt(it.y >= 0)
        .filterIt(it.y < map.height)
    )
    var innerCandidates : seq[Coord]
    for x in 0..map.width - 1:
        # echo x
        for y in 0.. map.height - 1:
            if (x, y) in pipe:
                # stdout.write 'P'
                continue
            if (x, y) in outerCandidates:
                # stdout.write 'O'
                continue
            # stdout.write 'I'
            innerCandidates.add((x,y))
        # stdout.write '\n'
    # echo map.width * map.height
    # echo map.width
    # echo map.height
    # echo pipe.len
    # echo outerCandidates.len
    # echo innerCandidates.len
    # echo pipe

    # echo "====Inner====="
    # echo innerCandidates
    # echo "====Outer====="
    # echo outerCandidates
    var previousUnknownCount = high(int)
    while innerCandidates.len != previousUnknownCount:
        previousUnknownCount = innerCandidates.len
        echo &"In current iteration: <={previousUnknownCount} possible inner points"
        # draw(pipe, outerCandidates, innerCandidates, map)
        var nextInners : seq[Coord]
        for cand in innerCandidates:
            var neighbor : Coord
            for d in qDir:
                neighbor = cand + QDirDelta[d]
                if neighbor in outerCandidates:
                    outerCandidates.add(cand)
                    break
            if not (cand in outerCandidates):
                nextInners.add(cand)
        innerCandidates = nextInners
        # echo innerCandidates.len
    draw(pipe, outerCandidates, innerCandidates, map)
    return innerCandidates.len



let x3 = """
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
"""



let x4 = """
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
"""

let x5 = """
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
"""

proc test2() =
    let x2p = parseInput(x2)
    assert findInner(x2p) == 1
    let x3p = parseInput(x3)
    assert findInner(x3p) == 4
    let x4p = parseInput(x4)
    # echo "x4"
    assert findInner(x4p) == 8
    let x5p = parseInput(x5)
    assert findInner(x5p) == 10

test2()

# echo findInner(fp)

