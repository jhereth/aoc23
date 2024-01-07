import std/math
import std/sequtils
import std/strutils
import std/enumerate
import typetraits

let part1 = """
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
"""

type Card = object
    id: int
    winning: seq[int]
    holding: seq[int]

proc parseToCard(s: string): Card =
    # echo "pTC: " & s
    let id = s.split(":")[0].splitWhitespace[1].parseInt
    let numbers = s.split(":")[1]
    let winning = numbers.split("|")[0].splitWhitespace.mapIt(it.parseInt)
    let holding = numbers.split("|")[1].splitWhitespace.mapIt(it.parseInt)
    return Card(
        id: id,
        winning: winning,
        holding: holding)

let exampleCard = Card(
    id: 1,
    winning: @[41, 48, 83, 86, 17],
    holding: @[83, 86, 6, 31, 17, 9, 48, 53],
    )
assert parseToCard("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53") == exampleCard

proc winningNumbers(card:Card): int =
    for h in card.holding:
        if card.winning.contains(h):
            result += 1

proc cardValue(card: Card): int =
    let count = winningNumbers(card)
    if count > 0:
        result += 2^(count - 1)

assert cardValue(exampleCard) == 8

for (line, expected) in zip(part1.splitLines, @[8, 2, 2, 1, 0, 0]):
    assert line.parseToCard.cardValue == expected

proc deckValue(deck: string) : int =
    for line in deck.splitLines:
        if line.len == 0: continue
        # echo "foo: " & line & " " & $result
        result += line.parseToCard.cardValue

assert deckValue(part1) == 13

let file = readFile("input.txt")
echo deckValue(file)

proc verifyContinuous(s: string) : bool =
    result = true
    var i = 0
    for line in s.splitLines:
        if line.len == 0: continue
        let card = line.parseToCard
        # echo card
        # echo i
        if card.id != i + 1:
            return false
        i = card.id

assert verifyContinuous(part1)
assert verifyContinuous(file)

proc winCopies(deck: string) : int =
    let cards = toSeq deck.splitLines.mapIt(if it.len == 0: -1 else: it.parseToCard.winningNumbers).filterIt(it >= 0)
    var cardCounts = newSeqWith(cards.len, 1)
    # echo cards
    echo cardCounts
    for i, c in enumerate(cards):
        echo $i & " (" & $c & ")"
        for j in (i+1) .. (i+c):
            cardCounts[j] += cardCounts[i]
        echo cardCounts
    cardCounts.sum
assert winCopies(part1) == 30
echo winCopies(file)