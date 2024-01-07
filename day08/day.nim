import std/math 
import std/sequtils
import std/strutils
import std/re
import std/tables

let ex1 = """
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
"""

type Node = tuple[L, R: string]
type Map = object
    path: string
    nodes: Table[string, Node]


proc parseInput(s: string) :  Map =
    let lines = s.splitLines
    result.path = lines[0]
    for line in lines[2..^1]:
        if line.len == 0: continue
        # echo line
        var matches = newSeq[string](3)
        discard line.find(re"^(\w+) = \((\w+), (\w+)\)", matches)
        let this = matches[0]
        assert not (this in result.nodes)
        result.nodes[this] = (matches[1], matches[2])

let ex1p = parseInput(ex1)

proc countSteps(m: Map, now : string = "AAA") : int =
    var now = now
    var i = 0
    while now[^1] != 'Z':
        if m.path[i] == 'L':
            now = m.nodes[now].L
        else:
            now = m.nodes[now].R
        i = (i + 1) mod m.path.len
        if result mod 32 == 0:
            echo "Working on step " & $result
        result += 1

assert countSteps(ex1p) == 2
let exp2 = """
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
"""

let x2p = parseInput(exp2)
assert countSteps(x2p) == 6

let file = readFile("input.txt")
let p1 = parseInput(file)
# echo countSteps(p1)

let x3 = """
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"""

let x3p = parseInput(x3)

proc ghostSteps(m: Map) : int =
    var nows = m.nodes.keys.toSeq.filterIt(it[^1] == 'A')
    echo "we are at " & $nows.len & " places at once"
    echo nows
    var cycles : seq[int]
    for node in nows:
        cycles.add(countSteps(m, node))
    result = cycles[0]
    if cycles.len == 1:
        return result
    for x in cycles[1..^1]:
        result = lcm(result, x)
    


assert ghostSteps(x3p) == 6
# assert ghostSteps(p1) == 12833235391111