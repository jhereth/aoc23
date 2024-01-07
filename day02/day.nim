import std/enumerate
import std/sequtils
import std/strutils
import std/strformat
import std/re



type Cubes* = object
    red*: int = 0
    green*: int = 0
    blue*: int = 0

proc `<=`(lhs, rhs: Cubes): bool =
    return lhs.red <= rhs.red and lhs.green <= rhs.green and lhs.blue <= rhs.blue

proc update(lhs, rhs: Cubes): Cubes =
    result.red = max(lhs.red, rhs.red)
    result.green = max(lhs.green, rhs.green)
    result.blue = max(lhs.blue, rhs.blue)

type Game* = object
    id*: int
    draws*: seq[Cubes]


proc possible(game: Game; ask: Cubes): int =
    if game.draws.allIt(it <= ask):
        return game.id
    return 0


proc stringToGame(s: string): Game =
    var matches = newSeq[string](1)
    discard find(s, re"^Game +(\d+):", matches)
    let id = parseInt(matches[0])
    var draws = newSeq[Cubes](0)
    for d in s.split(":")[1].split(";"):
        var draw: Cubes
        for c in d.split(","):
            let count = c.splitWhitespace[0]
            let color = c.splitWhitespace[1]
            case color:
                of "red":
                    draw.red = count.parseInt
                of "green":
                    draw.green = count.parseInt
                of "blue":
                    draw.blue = count.parseInt
                else:
                    raiseAssert "wrong stuff" & c
        draws.add(draw)
    return Game(id: id, draws: draws)

assert Cubes(blue: 3, red: 4) == Cubes(red: 4, green: 0, blue: 3)
let x1 = stringToGame(
    "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
    )
assert x1 == Game(
        id: 1,
        draws: @[
            Cubes(blue: 3, red: 4),
            Cubes(red: 1, green: 2, blue: 6),
            Cubes(green: 2),
    ])

let part1 = """
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"""

let ask1 = Cubes(red: 12, green: 13, blue: 14)



proc games(gamelist: string; ask: Cubes): int =
    for line in gamelist.splitLines:
        if len(line) == 0: continue
        let game = stringToGame(line)
        result += possible(game, ask1)


for game in part1.splitLines:
    echo game
    if len(game) > 0:
        echo stringToGame(game)

assert games(part1, ask1) == 8

let entireFile = readFile("input.txt")
# echo entireFile
let ask = Cubes(red: 12, green: 13, blue: 14)
echo games(entireFile, ask)

proc power(game: Game): int =
    var minCube: Cubes
    for d in game.draws:
        minCube = minCube.update(d)
    # echo minCube
    return minCube.red * minCube.green * minCube.blue

for line in part1.splitLines:
    if len(line) == 0: continue
    let game = stringToGame(line)
    echo power(game)

var result2: int
for line in entireFile.splitLines:
    if len(line) == 0: continue
    result2 += power(stringToGame(line))
echo result2
