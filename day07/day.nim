import std/enumerate
import std/algorithm
import std/sequtils
import std/strutils
import std/tables

let part1 = """
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
"""
let cardOrder = "AKQJT98765432"

proc kind(self: string) : string = 
    $self.toCountTable.values.toSeq.sorted(Descending)

type Bid = object
    cards: string
    money: int

proc camelComp(lhs, rhs: Bid) : int =
    if lhs.cards.kind == rhs.cards.kind:
        assert lhs.cards.len == rhs.cards.len
        for i in 0 .. lhs.cards.len - 1:
            let l = lhs.cards[i]
            let r = rhs.cards[i]
            if l == r:
                continue
            return -cmp(cardOrder.find(l), cardOrder.find(r))
        return 0
    return cmp(lhs.cards.kind, rhs.cards.kind)

let x1 = Bid(cards: "KK677",money: 23)
let x2 = Bid(cards: "KTJJT", money: 42)
# echo x1
# echo x2
# echo camelComp(x1, x2)
var f = @[x1, x2, x2, x1, x1, x2, x1]
sort(f, camelComp)
echo f

proc parseInput(s: string) : seq[Bid] =
    for line in s.splitLines:
        if line.len == 0: continue
        result.add(
            Bid(
                cards: line.splitWhitespace[0],
                money: line.splitWhitespace[1].parseInt
            )
        )
let parse1 = parseInput(part1)

proc evaluate(bids: seq[Bid]) : int =
    var bids = bids
    sort(bids, camelComp)
    for rank, b in enumerate(bids):
        echo b
        result += (rank + 1) * b.money
        echo result

echo evaluate(parse1)

let file = readFile("input.txt")
let parsed = parseInput(file)
echo evaluate(parsed)

let newOrder = "AKQT98765432J"

proc jokerKind(self: string) : string = 
    # echo "foo"
    # echo self
    let jCount = self.count("J")
    var counts = self.replace("J", "").toCountTable.values.toSeq.sorted(Descending)
    # echo counts
    if counts.len > 0:
        counts[0] += jCount
        # echo counts
        return $counts
    return "@[5]"

echo jokerKind("T55J5")
echo jokerKind("AAAAA")
echo jokerKind("JJJJJ")

proc jokerComp(lhs, rhs: Bid) : int =
    if lhs.cards.jokerKind == rhs.cards.jokerKind:
        assert lhs.cards.len == rhs.cards.len
        for i in 0 .. lhs.cards.len - 1:
            let l = lhs.cards[i]
            let r = rhs.cards[i]
            if l == r:
                continue
            return -cmp(newOrder.find(l), newOrder.find(r))
        return 0
    return cmp(lhs.cards.jokerKind, rhs.cards.jokerKind)

proc jokulate(bids: seq[Bid]) : int =
    var bids = bids
    sort(bids, jokerComp)
    for rank, b in enumerate(bids):
        echo b
        result += (rank + 1) * b.money
        echo result

echo jokulate(parse1)
echo jokulate(parsed)

var j, notj : int
for b in parsed:
    if b.cards.find("J") == -1:
        assert b.cards.kind == b.cards.jokerKind
        notj += 1
    else:
        assert b.cards.kind <= b.cards.jokerKind
        j += 1
echo j
echo notj
echo parsed.len