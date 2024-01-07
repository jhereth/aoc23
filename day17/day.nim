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

proc flip(dir: Dir) : Dir =  # /
    {L: D, R: U, D: L, U: R}.toTable[dir] 

proc flop(dir: Dir) : Dir =  # \
    {L: U, R: D, D: R, U: L}.toTable[dir] 

proc `-`(dir: Dir) : Dir =
    {L: R, R: L, D: U, U: D}.toTable[dir]

type Pos = (int, int)

proc `*`(factor: int, dir: Dir) : Pos =
        result[0] = {U: -factor, D: factor}.toTable.getOrDefault(dir, 0)
        result[1] = {L: -factor, R: factor}.toTable.getOrDefault(dir, 0)

proc `+`(lhs, rhs: Pos) : Pos =
    result[0] = lhs[0] + rhs[0]
    result[1] = lhs[1] + rhs[1]

proc `+`(pos: Pos, dir: Dir) : (int, int) =
    result = pos + (1 * dir)


type Node = (Pos, Dir, int)
const nilNode : Node = ((low(int), low(int)), L, low(int))  # !! <- can't be used as normal value

type Cost = int

type Candidate = object
    priority: int
    node: Node

proc `<`(lhs, rhs: Candidate): bool =
    lhs.priority < rhs.priority

let x1 = """
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
"""

type Grid = object
    width, height : int
    map : seq[seq[Cost]]

proc get(g: Grid, p: Pos) : Cost =
    g.map[p[0]][p[1]]

proc parseInput(s: string) : Grid =
    result.map = s.splitLines.filterIt(it.len > 0).mapIt(it.mapIt(($it).parseInt))
    result.height = result.map.len
    result.width = result.map[0].len
    for line in result.map:
        assert line.len == result.width
        assert line.min >= 1
        if line.min > 1:
            echo &"Lowest Number: {line.min}"


let x1p = x1.parseInput



proc simpleNeighbours(n: Node, g: Grid) : iterator(): Node =
    return iterator(): Node =
        for d in QDir:
            var remaining = 2
            if d == U and n[0][0] == 0: continue
            if d == L and n[0][1] == 0: continue
            if d == D and n[0][0] == g.height - 1 : continue
            if d == R and n[0][1] == g.width - 1 : continue
            if d == -n[1]: continue
            if d == n[1]:
                if n[2] == 0: continue
                remaining = n[2] - 1
            yield (n[0] + d, d, remaining)


proc simpleCost(start, goal: Node, grid: Grid) : Cost =
    grid.get(goal[0])

proc heuristic(n: Node, grid: Grid) : Cost =
    grid.height - n[0][0] + grid.width - n[0][1]

proc isGoal(n: Node, grid: Grid) : bool =
    (n[0][0] == grid.height - 1) and
    (n[0][1] == grid.width - 1)

proc draw(grid: Grid, path: seq[Node]) =
    let pathPos = path.mapIt(it[0])
    for i in 0 ..< grid.height:
        for j in 0 ..< grid.width:
            if (i, j) in pathPos:
                stdout.write(grid.get((i,j)))
            else:
                stdout.write(".")
        stdout.write("\n")


proc reconstructPath(start, current: Node, cameFrom: TableRef[Node, Node]) : seq[Node] = 
    var current = current
    while current != start:
        result.add(current)
        current = cameFrom[current]
    result.add(start)

proc findWay(
    grid: Grid,
    start: Node,
    neighbours: proc (n: Node, g: Grid): iterator (): Node,
    cost: proc (start, goal: Node, grid: Grid) : Cost,
    ) : int =
    echo &"Grid has size {grid.height}x{grid.width}"
    var costSoFar = newTable[Node, Cost]()
    costSoFar[start] = 0
    var frontier = initHeapQueue[Candidate]()
    frontier.push(Candidate(node: start, priority: 0))
    var cameFrom = newTable[Node, Node]()
    cameFrom[start] = nilNode
    var current = nilNode
    while frontier.len > 0:
        current = frontier.pop.node
        # echo "current node is " & $current
        if isGoal(current, grid):
            break
        for next in neighbours(current, grid):
            let newCost = costSoFar[current] + cost(current, next, grid)
            # echo &"{current[0]} -> {next}: {newCost}"
            var oldCost : Cost
            try:
                oldCost = costSoFar[next]
            except:
                oldCost = high(Cost)
            if newCost < oldCost:
                costSoFar[next] = newCost
                let priority = newCost + heuristic(next, grid)
                frontier.push(Candidate(node: next, priority: priority))
                cameFrom[next] = current
    let path = reconstructPath(start, current, cameFrom)
    # echo path
    grid.draw(path)
    # echo current, costSoFar[current]
    return costSoFar[current]

let start: Node = ((0, 0), R, 3)

let x1pr = findWay(x1p, start, simpleNeighbours, simpleCost)
assert x1pr == 102
echo &"Part 1: Ex1: {x1pr}"


let file = readFile("input.txt")
let fp = file.parseInput
# let fpr = findWay(fp, start, simpleNeighbours)
# echo fpr
# assert fpr == 755
# echo &"Part 1: File: {fpr}"

let superStart : Node = ((0,0), R, int.low)
proc superNeighbours(n: Node, grid: Grid) : iterator(): Node =
    return iterator(): Node =
        for d in QDir:
            # echo &"Dir {d} from {n}"
            if n[2] != int.low:  # First step might go into two orthogonal directions which usually is not the case
                if d == -n[1]: continue
                if d == n[1] : continue
            for steps in 4..10:
                let next = n[0] + (steps * d)
                if next[0] < 0: continue
                if next[0] >= grid.height: continue
                if next[1] < 0: continue
                if next[1] >= grid.width: continue
                # echo &"yield {next}"
                yield (next, d, 0)

proc superCost(start, goal: Node, grid: Grid) : Cost =
    let startPos = start[0]
    let goalPos = goal[0]
    for i in min(startPos[0], goalPos[0]) .. max(startPos[0], goalPos[0]):
        for j in min(startPos[1], goalPos[1]) .. max(startPos[1], goalPos[1]):
            result += grid.get((i,j))
    result -= grid.get(startPos)
        

let x1pr2 = x1p.findWay(superStart, superNeighbours, superCost)
echo x1pr2
assert x1pr2 == 94
echo &"Part 2: Ex1: {x1pr2}"


let x2 = """
111111111111
999999999991
999999999991
999999999991
999999999991
"""

let x2r = x2.parseInput.findWay(superStart, superNeighbours, superCost)
assert x2r == 71
echo &"Part 2: Ex2: {x1pr2}"

let fr2 = fp.findWay(superStart, superNeighbours, superCost)
echo &"Part 2: Firle: {fr2}"
