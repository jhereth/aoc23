import std/algorithm
import std/enumerate
import std/heapqueue
import std/math
import std/sequtils
import std/sets
import std/strformat
import std/strutils
import std/tables
import std/typetraits
import memo

# for A* see Day 17
# for counts of inner points see Day 18
type Pulse = enum Low, High

let x1 = """
broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
"""

let x2 = """
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
"""

proc parseInput(s: string): (Table[string, char], Table[string, seq[string]],
        Table[string, seq[string]]) =
    let splitted = s.splitLines.filterIt(it.len > 0)
    var modTypes: Table[string, char]
    var sendRecs: Table[string, seq[string]]
    var modSources: Table[string, seq[string]]
    for line in splitted:
        let typ = line[0]
        let sendRecStr = line[1..line.high].split(" -> ")
        if typ == 'b': assert line[0..10] == "broadcaster"
        let sender = sendRecStr[0]
        modTypes[sender] = typ
        sendRecs[sender] = sendRecStr[1].split(", ")
    # echo &"modTypes={modTypes}"
    for module in sendRecs.keys:
        let receivers = sendRecs[module]
        # echo &"module {module} is of type {modTypes[module]} and sends to {receivers}"
        for rec in receivers:
            try:
                if modTypes[rec] != '&': continue
            except:
                echo &"Note: `{rec}` appears as recipient, but not in sender list"
                continue
            var sources = modSources.getOrDefault(rec, @[])
            sources.add(module)
            modSources[rec] = sources.deduplicate
    (modTypes, sendRecs, modSources)







proc part2(
    modType: Table[string, char],
    modTo: Table[string, seq[string]],
    modFrom: Table[string, seq[string]],
    ): tuple[low, high: int] =
    var rxLow = false
    var signals: seq[(string, string, Pulse)] = @[("button", "roadcaster", Low)]
    var ffState: Table[string, bool]
    for module in modType.keys:
        if modType[module] == '%':
            ffState[module] = false
    var conjState: Table[string, TableRef[string, Pulse]]
    for conj in modFrom.keys:
        var nT = newTable[string, Pulse]()
        conjState[conj] = nT
        for src in modFrom[conj]:
            conjState[conj][src] = Low
    # echo state
    proc oneStep(
        ffState: Table[string, bool],
        conjState: Table[string, TableRef[string, Pulse]],
        signals: seq[(string, string, Pulse)],
    ): (tuple[low, high: int], Table[string, bool], Table[string, TableRef[string, Pulse]]) =
        if signals.len == 0: return ((0, 0), ffState, conjState)
        let (sender, module, pulse) = signals[0]
        if ((module == "rx" and pulse == Low)):
            # end of part 2!
            rxLow = true
            return
        # echo &"{sender}->{module}: {pulse}"
        var low, high = 0
        if pulse == Low:
            low += 1
        else:
            high += 1
        var signals = signals[1..signals.high]
        var ffState = ffState
        var conjState = conjState
        var typ: char
        var skip = false
        var addRec = true
        try:
            typ = modType[module]
        except:
            # echo &"Cannot determine type for module {module}. Assume this is terminal"
            skip = true
            addRec = false
            typ = 'X'
        var newPulse : Pulse
        case typ:
            of 'b':
                newPulse = pulse
            of '%':
                if pulse == High:
                    addRec = false
                else:
                    let oldState = ffState[module]
                    newPulse = {true: Low, false: High}.toTable[oldState]
                    ffState[module] = not oldState
            of '&':
                conjState[module][sender] = pulse
                # echo &"conjstate for {module}: {conjState[module]}"
                if conjState[module].keys.toSeq.allIt(conjState[module][it] == High): newPulse = Low
                else: newPulse = High
                # echo &"newPulse={newPulse}"
                # echo &"Existing signals: {signals}"
            else:
                if not skip:
                    raise newException(ValueError,
                            &"unknown module type {modType[module]} for module {module} found.")
        if addRec:
            for rec in modTo[module]:
                signals.add((module, rec, newPulse))
        # echo &"End of {module}: signals={signals}"
        var newLow, newHigh: int
        ((newLow, newHigh), ffState, conjState) = oneStep(ffState, conjState, signals)
        return ((low + newLow, high + newHigh), ffState, conjState)
    var low, high = 0
    var buttonPresses = 0
    while true:
        # echo &"==== Round {i} ====="
        buttonPresses += 1
        var newLow, newHigh = 0
        ((newLow, newHigh), ffState, conjState) = oneStep(ffState, conjState, signals)
        low += newLow
        high += newHigh
        if rxLow:
            echo &"rx received Low pulse after {buttonPresses} button presses!"
            echo &"There were so far {low} low and {high} high pulses."
            break
        if buttonPresses mod 10_000 == 0:
            echo &"{buttonPresses // 10_000}"
    (low, high)

# proc test1() =
#     let (mT1, sR1, mS1) = x1.parseInput
#     let x1p = part1(mT1, sR1, mS1)
#     let x1pr = x1p[0] * x1p[1]
#     # echo x1pr
#     assert x1pr == 32_000_000
#     let (mT2, sR2, mS2) = x2.parseInput
#     let x2p = part1(mT2, sR2, mS2)
#     let x2pr = x2p[0] * x2p[1]
#     # echo x2pr
#     assert x2pr == 11687500

# test1()


# proc final1() =
#     let file = readFile("input.txt")
#     let (mTf, sRf, mSf) = file.parseInput
#     let fp = part1(mTf, sRf, mSf)
#     echo fp
#     let fpr = fp[0] * fp[1]
#     echo fpr
#     assert fpr == 743090292

# final1()

proc final2() =
    let file = readFile("input.txt")
    let (mTf, sRf, mSf) = file.parseInput
    let fp = part2(mTf, sRf, mSf)
    echo fp
    # let fpr = fp[0] * fp[1]
    # echo fpr

final2()
