import std/enumerate
import std/math
import std/sequtils
import std/strformat
import std/strutils

import memo

let x1 = """
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
"""

type Record = object
    damaged: string
    groups: seq[int]

proc parseInput(s: string) : seq[Record] =
    for line in s.splitLines.filterIt(it.len > 0):
        result.add(
            Record(
                damaged: line.splitWhitespace[0],
                groups: line.splitWhitespace[1].split(',').map(parseInt),
            )
        )

let x1p = x1.parseInput
# for r in x1p:
#     echo fmt"{sum(r.groups)} -> {r.damaged.len}"


proc arrangements(s: string, groups: seq[int]) : int {.memoized.} =
    # echo fmt"s={s}, groups={groups}"
    if groups.len == 0:
        if "#" in s:
            return 0
        return 1
    if groups.sum + groups.len - 1 > s.len:
        return 0
    let dam = s.strip(chars={'.'})
    if dam.len == 0:
        return 0
    if dam.len < s.len:
        return arrangements(dam, groups)
    if dam[0] == '?':
        result = arrangements(dam[1..^1], groups)
    # echo fmt"--> dam={dam}, groups={groups}"
    if "." in dam[0 ..< groups[0]]:
        return result
    if dam.len > groups[0] and (dam[groups[0]] == '#'):
        return result
    if dam.len == groups[0] or dam.len == (groups[0] + 1):
        return result + 1
    # echo groups[0]
    # echo fmt"|{dam[groups[0]..dam.high]}|"
    let restString = dam[groups[0] + 1 .. dam.high]
    let restGroups = groups[1 .. ^1]
    result += arrangements(restString, restGroups)





let expected1 = @[1, 4, 1, 1, 4, 10]
for i, r in enumerate(x1p):
    # echo fmt"New: {r} ({i})"
    let ass = arrangements(r.damaged, r.groups)
    # echo fmt"got: |{ass}|"
    # echo ass.len #== expected1[i]
    # echo i
    # echo expected1[i]
    assert ass == expected1[i], fmt"got {ass}, expected {expected1[i]} (Test {i})"

# echo "?###???????? 3,2,1".parseInput.mapIt(arrangements(it.damaged, it.groups))

assert x1p.mapIt(arrangements(it.damaged, it.groups)).sum == 21
let file = readFile("input.txt")
var su = 0
# for r in file.parseInput:
#     echo r
#     let a = arrangements(r.damaged, r.groups)
#     su += a
#     echo fmt"{a} -> {su}"
# echo su
assert file.parseInput.mapIt(arrangements(it.damaged, it.groups)).sum == 7169

let x2 = """
.# 1
"""
proc explodeRecord(r: Record) : Record =
    result.damaged = @[r.damaged].cycle(5).foldl(a & "?" & b)
    result.groups = r.groups.cycle(5)

assert  x2.parseInput.map(explodeRecord) == @[Record(damaged: ".#?.#?.#?.#?.#", groups: @[1, 1, 1, 1, 1])]
# echo  @["abc"].cycle(5).foldl(a & "?" & b)
# echo x

let expected2 = @[1, 16384, 1, 16, 2500, 506250]
for i, it in enumerate(x1.parseInput.map(explodeRecord)):
    let act = arrangements(it.damaged, it.groups)
    assert act == expected2[i], fmt"act={act}, expected={expected2[i]} for {it} (Test {i})"

let part2 = file.parseInput.map(explodeRecord).mapIt(arrangements(it.damaged, it.groups)).sum
assert part2 == 1738259948652
echo part2