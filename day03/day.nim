import std/enumerate
import std/sequtils
import std/strutils
import std/strformat
import std/re
import std/tables
import std/sets

type PartPos* = object
    line* : int = 0
    first* : int = 0
    last* : int = 0
    content* : int = 0

# proc `<=`(lhs, rhs: Cubes) : bool =
#     return lhs.red <= rhs.red and lhs.green <= rhs.green and lhs.blue <= rhs.blue


let part1 = """
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
"""

iterator findAllBounds(buf: string; pattern: Regex, start : int = 0): tuple[first, last: int] =
    var b = buf.findBounds(pattern, start=start)
    while b.first != -1:
        yield b
        b = findBounds(buf, pattern, start=b.last + 1)

proc findParts(map: string) : seq[PartPos] =
    var symbolPositions = newSeq[seq[int]](0)
    for line in map.splitLines:
        var poss = newSeq[int](0)
        for p in line.findAllBounds(re"[^0-9\.]"):
            poss.add(p.first)
        symbolPositions.add(poss)
    # echo symbolPositions
    var partPositions = newSeq[PartPos]()
    for i, line in enumerate(map.splitLines):
        for x in line.findAllBounds(re"\d+"):
            let match = line[x.first .. x.last]
            let candidate = PartPos(
                line: i,
                first: x.first,
                last: x.last,
                content: match.parseInt
            )
            block symbolsearch:
                for sl in symbolPositions[max(0,i-1) .. min(len(symbolPositions), i+1)]:
                    for p in sl:
                        if (x.first-1 <= p) and (p <= x.last + 1):
                            partPositions.add(candidate)
                            break symbolsearch
    return partPositions

let part1parts = findParts(part1)
proc solve1(parts: seq[PartPos]) : int =
    for p in parts:
        result += p.content

# echo part1parts
# echo part1parts.len
echo solve1(part1parts)
# echo part1



proc mapParts(parts: seq[PartPos]) : seq[seq[PartPos]] =
    var lineCount = 0
    for p in parts:
        lineCount = max(lineCount, p.line)
    var partsSeq = newSeq[seq[PartPos]](lineCount + 1)
    for p in parts:
        partsSeq[p.line].add(p)
    return partsSeq

let partMap1 = mapParts(part1parts)

proc findGears(plan: string, partMap : seq[seq[PartPos]]) : seq[tuple[one, two: int]] =
    for i, line in enumerate(plan.splitLines):
        # echo "line " & $i
        for x in line.findAllBounds(re"\*"):
            var attachedParts = newSeq[PartPos](0)
            for pl in partMap[max(0, i-1) .. min(partMap.len - 1, i + 1)]:
                for p in pl:
                    if (p.first - 1 <= x.first) and (x.first <= p.last + 1):
                        attachedParts.add(p)
            if attachedParts.len == 2:
                result.add((attachedParts[0].content, attachedParts[1].content))

echo findGears(part1, partMap1)

proc solve2(plan: string, partMap: seq[seq[PartPos]]) : int =
    let gears = findGears(plan, partMap)
    for g in gears:
        result += g.one * g.two

echo solve2(part1, partMap1)

let entireFile = readFile("input.txt")
let entireParts = findParts(entireFile)
echo solve1(entireParts)
let partMap2 = mapParts(entireParts)
echo solve2(entireFile, partMap2)