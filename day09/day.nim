import std/algorithm
import std/math
import std/sequtils
import std/strutils

let x1 = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""

type Series = seq[int]

proc parseInput(s: string) : seq[Series] =
    s.splitLines.filterIt(it.len > 0).mapIt(it.splitWhitespace.map(parseInt))

let x1p = parseInput(x1)
# echo x1p

let s1 = x1p[1]


proc derive(s: Series) : seq[Series] =
    # echo s
    var current = s
    while not current.allIt(it == 0):
        result.add(current)
        var diffs = zip(current[0 .. ^2], current[1 .. ^1]).mapit(it[1] - it[0])
        # echo diffs
        current = diffs

proc predict(s: Series) : int =
    derive(s).mapIt(it[^1]).sum

let x1pp = x1p.map(predict)
echo x1pp
assert x1pp == @[18, 28, 68]

let file = readFile("input.txt")
let fp = parseInput(file)
let fr = fp.map(predict).sum
echo fr

proc foredict(s: Series): int =
    # echo s
    let firsts = derive(s).mapIt(it[0]).reversed
    # echo firsts
    result = firsts[0]
    for up in firsts[1..^1]:
        result = up - result

# echo foredict(x1p[2])
let x1r2 = x1p.map(foredict)
# echo x1r2
assert x1r2 == @[-3, 0, 5]
let fr2 = fp.map(foredict).sum
echo fr2
assert fr2 == 975