import std/sequtils
import std/strutils

let part1 = """
Time:      7  15   30
Distance:  9  40  200
"""
type Race = tuple[time, dist: int]

proc parseInput(s: string) : seq[Race] =
    let times = s.splitLines[0].split(":")[1].splitWhitespace.map(parseInt)
    let distances = s.splitLines[1].split(":")[1].splitWhitespace.map(parseInt)
    return zip(times, distances)


let parsed1 = parseInput(part1)

proc oneGame(time, dist: int) : int =
    for button in 0 .. time:
        if (time - button) * button > dist:
            result += 1

assert parsed1.mapIt(oneGame(it.time, it.dist)) == @[4, 8, 9]

proc margin(races: seq[Race]) : int =
    result = 1
    for race in races:
        result *= oneGame(race.time, race.dist)

assert margin(parsed1) == 288


let file = readFile("input.txt")
let parsed = parseInput(file)
echo margin(parsed)

assert oneGame(71530, 940200) == 71503

proc parseNoKern(s: string) : Race =
    parseInput(s.replace(" ", ""))[0]

assert parseNoKern(part1) == (71530, 940200)



let parsedNoKern = parseNoKern(file)
echo parsedNoKern
echo oneGame(parsedNoKern.time, parsedNoKern.dist)