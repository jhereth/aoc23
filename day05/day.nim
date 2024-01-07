import std/algorithm
import std/math
import std/sequtils
import std/strutils
import std/enumerate
import typetraits

let part1 = """
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""

type Mapping = tuple[length, src_start, dest_start: int]


type Map = object
    name: string
    mappings: seq[Mapping]

type Game = object
    seeds: seq[int]
    maps: seq[Map]

proc parseInput(s: string) : Game =
    let lines = s.splitLines
    assert lines[0][0 .. 6] == "seeds: "
    result.seeds = lines[0].split(":")[1].splitWhitespace.map(parseInt)
    var currentMap = Map()
    var currentMapping : Mapping
    for i in 1 .. len(lines) - 1:
        let line = lines[i]
        if line.len == 0: continue
        if line[^5 .. ^1] == " map:":
            currentMap.name = line[0 .. ^6]
        else:
            let numbers = line.splitWhitespace.map(parseInt)
            currentMapping.dest_start = numbers[0]
            currentMapping.src_start = numbers[1]
            currentMapping.length = numbers[2]
            currentMap.mappings.add(currentMapping)
        if lines[i+1].len == 0:
            currentMap.mappings.sort()
            result.maps.add(currentMap)
            currentMap.name = "unknown"
            currentMap.mappings = @[]

let game1 = parseInput(part1)
echo game1
proc processMap(input: seq[int], map: Map) : seq[int] =
    for i in input:
        echo "processing " & $i & " for " & map.name
        block process_mappings:
            for m in map.mappings:
                if (m.src_start <= i) and (i < m.src_start + m.length):
                    result.add(i - m.src_start + m.dest_start)
                    break process_mappings
            result.add(i)
        # echo $i & " -> " & $result


# echo processMap(game1.seeds, game1.maps[0])

proc processGame(game: Game) : int =
    var current = game.seeds
    echo current
    for map in game.maps:
        current = processMap(input=current, map=map)
        echo map.name
        echo current
    return min(current)


echo processGame(game1)

let file = readFile("input.txt")
let fullgame = parseInput(file)
echo processGame(fullgame)

type Interval = tuple[left, width: int]
proc processRangeSeeds(seeds: seq[int]) : seq[Interval] =
    assert len(seeds) mod 2 == 0
    for i in 0 .. (len(seeds) div 2) - 1:
            result.add((seeds[2*i], seeds[2*i + 1]))

echo len(processRangeSeeds(game1.seeds))


proc processMapWithInterVals(input: seq[Interval], map: Map) : seq[Interval] =
    var input = input
    echo map.name
    echo map.mappings
    echo input.len
    while input.len > 0:
        var i = input.pop
        # echo "input len=" & $input.len
        block mappingsLoop:
            for m in map.mappings:
                if m.src_start + m.length <= i.left: continue
                if m.src_start <= i.left:
                    if i.left + i.width <= m.src_start + m.length:
                        result.add((i.left + m.dest_start - m.src_start, i.width))
                        break mappingsLoop
                    input.add((m.src_start + m.length, i.left + i.width - m.src_start - m.length))
                    result.add((i.left + m.dest_start - m.src_start, m.src_start + m.length - i.left + 1))
                    break mappingsLoop
                if m.src_start <= i.left + i.width:
                    input.add((m.src_start, i.left + i.width - m.src_start))
                    i.width = m.src_start - i.left
                    continue
            result.add(i)
    echo result
    result

proc processRangeGame(game: Game): int =
    var current = processRangeSeeds(game.seeds)
    echo current.len
    echo current
    for map in game.maps:
        current = processMapWithInterVals(input=current, map=map)
        echo current.len
    echo "result"
    echo current
    echo min(current.mapIt(it.left))
    return min(current.mapIt(it.left))

# echo processRangeGame(game1)
assert processRangeGame(game1) == 46
# echo "Finally"
echo processRangeGame(fullgame)
