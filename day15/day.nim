import std/enumerate
import std/math
import std/sequtils
import std/strformat
import std/strutils
import std/typetraits

proc hhh(s: string) : int =
    for c in s:
        result += ord(c)
        result *= 17 
        result = result mod 256

assert hhh("HASH") == 52
let x1 = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
assert x1.split(",").map(hhh).sum == 1320

let file = readFile("input.txt")
let fileSplit = file.splitLines[0].split(",")
assert fileSplit.map(hhh).sum == 510792

type Lens = (string, int)

proc focusPower(box: seq[Lens]) : int =
    for i in 0 .. box.high:
        result += (i+1) * box[i][1]

assert focusPower(@[("rn", 1), ("cm", 2)]) == 5
assert focusPower(@[("ot", 7), ("ab", 5) , ("pc", 6)]) == (28 + 40 + 72) div 4

proc initialize(s: string) : int =
    var boxes = newSeq[seq[Lens]](256)
    let ops = s.split(",")
    fmt"Processing {ops.len} operations".echo
    for op in ops:
        if "-" in op:
            let label = op.split("-")[0]
            let box = label.hhh
            fmt"removing label {label} from box {box}".echo
            boxes[box] = boxes[box].filterIt(it[0] != label)
        elif "=" in op:
            let label = op.split("=")[0]
            let box = label.hhh
            let focus = op.split("=")[1].parseInt
            fmt"Putting Lens {(label, focus)} into box {box}".echo
            var newBox = newSeq[Lens](0)
            var replaced = false
            for lens in boxes[box]:
                if lens[0] != label:
                    newBox.add(lens)
                else:
                    echo fmt"Found old lens {lens}. Putting {(label, focus)} there instead"
                    newBox.add((label, focus))
                    replaced = true
            if not replaced:
                newBox.add((label, focus))
            boxes[box] = newBox
        for i, box in enumerate(boxes):
            if box.len > 0:
                echo i, box
    for i, box in enumerate(boxes):
        result += (i+1) * box.focusPower

assert initialize(x1) == 145
echo initialize(file.splitLines[0])