import std/algorithm
import std/enumerate
import std/heapqueue
import std/json
import std/math
import std/sequtils
import std/sets
import std/strformat
import std/strutils
import std/tables
import std/typetraits

let x1 = """
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
"""

type Part = object
    x, m, a, s: int

type Workflow = object
    name: string
    rules: seq[string]

proc parseInput(s: string): (Table[string, Workflow], seq[Part]) =
    var emptyLines = 0
    for line in s.splitLines:
        if line.len == 0:
            emptyLines += 1
            continue
        if emptyLines == 0: # Workflows
            let name = line.split("{")[0]
            let rules = line[name.len + 1..<line.high].split(",")
            result[0][name] = Workflow(name: name, rules: rules)
        elif emptyLines == 1: # parts
            let vals = line[1..<line.high].split(",").mapIt(it.split("=")[
                    1]).map(parseInt)
            result[1].add(Part(x: vals[0], m: vals[1], a: vals[2], s: vals[3]))
    assert "in" in result[0]
    for key, wf in result[0]:
        # echo key
        for rule in wf.rules:
            var pre: string
            var cons: string
            if ":" in rule:
                pre = rule.split(":")[0]
                cons = rule.split(":")[1]
            else:
                cons = rule
            if pre.len > 0:
                assert pre[0] in "xmas"
                assert pre[1] in "<>"
                assert pre[2..pre.high].parseInt >= 0
            if not (cons in @["A", "R"]):
                assert cons in result[0]


let x1p = x1.parseInput

proc apply(wfs: Table[string, Workflow], p: Part, wf: string = "in",
        firstRule: int = 0): int =
    # echo &"going with {wf}"
    let wf = wfs[wf]
    let sp = wf.rules[firstRule].split(":")
    # echo &"Processing {sp} for {p}"
    if sp.len == 1:
        let n = sp[0]
        case n:
            of "R":
                return 0
            of "A":
                return p.x + p.m + p.a + p.s
            else:
                return wfs.apply(p, wf = n)
    let cond = sp[0]
    var x: int
    case cond[0]:
        of 'x': x = p.x
        of 'm': x = p.m
        of 'a': x = p.a
        of 's': x = p.s
        else:
            raise newException(ValueError, &"{cond} unexpected")
    let val = cond.split({'<', '>'})[1].parseInt
    # echo &"Value found: {val}"
    if (("<" in cond and x < val) or
    (">" in cond and x > val)):
        case sp[1]:
            of "R": return 0
            of "A": return p.x + p.m + p.a + p.s
            else:
                return wfs.apply(p, wf = sp[1])
    else:
        # echo &"No success for {sp} in {wf}, continuing to next Rule ({firstRule + 1}/{wf.rules.len})"
        return wfs.apply(p, wf=wf.name, firstRule=(firstRule + 1))


proc part1(s: string) : int =
    let (wfs, parts) = s.parseInput
    parts.mapIt(wfs.apply(it)).sum

proc test1()=
    assert x1p[0].apply(x1p[1][0]) == 7540
    assert x1p[0].apply(x1p[1][1]) == 0
    assert x1p[0].apply(x1p[1][2]) == 4623
    assert x1p[0].apply(x1p[1][3]) == 0
    assert x1p[0].apply(x1p[1][4]) == 6951
    assert x1.part1 == 19114


test1()
let file = readFile("input.txt")

proc final1() =
    let fr1 = file.part1
    assert fr1 == 374873
    echo fr1

final1()

type PartRange = object
    mins: Table[char, int]
    maxs: Table[char, int]


var minmins: Table[char, int]
var maxmaxs: Table[char, int]

for c in "xmas":
    minmins[c] = 1
    maxmaxs[c] = 4000

const AllPart = PartRange(
    mins : {'x': 1,'m': 1,'a': 1,'s': 1}.toTable,
    maxs : {'x': 4000,'m': 4000,'a': 4000,'s': 4000}.toTable
    )

proc count(pr: PartRange) : int =
    result = 1
    for c in "xmas":
        result *= (pr.maxs[c] - pr.mins[c] + 1)

proc apply2(wfs: Table[string, Workflow], pr: PartRange, wf: string = "in",
        firstRule: int = 0): int =
    proc finalApply(pr: PartRange, rule: string) : int =
        case rule:
            of "R":
                return 0
            of "A":
                return pr.count
            else:
                return wfs.apply2(pr, wf = rule)
    # echo &"going with {wf}"
    let wf = wfs[wf]
    let sp = wf.rules[firstRule].split(":")
    echo &"{wf.name} Rule {firstRule}/{wf.rules.len}: {sp} on {pr}"
    # echo &"Processing {sp} for {p}"
    if sp.len == 1:
        return pr.finalApply(sp[0])
    let cond = sp[0]
    let dim = cond[0]
    let op = cond[1]
    let val = cond.split(op)[1].parseInt
    let pMin = pr.mins[dim]
    let pMax = pr.maxs[dim]
    echo &"Value found: {dim} {op} {val} ({pMin}..{pMax})"
    case op:
        of '<':
            var newMins = pr.mins
            var newMaxs = pr.maxs
            if pMin < val:
                newMaxs[dim] = min(pMax, val - 1)
                result += PartRange(mins: newMins, maxs: newMaxs).finalApply(sp[1])
            if val <= pMax:
                newMaxs[dim] = pr.maxs[dim]  # restore
                newMins[dim] = max(pMin, val)
                result += wfs.apply2(PartRange(mins: newMins, maxs: newMaxs), wf.name, firstRule + 1)
        of '>':
            var newMins = pr.mins
            var newMaxs = pr.maxs
            if pMin <= val:
                newMaxs[dim] = min(pMax, val)
                result += wfs.apply2(PartRange(
                    mins: newMins, maxs: newMaxs
                ), wf.name, firstRule + 1)
            if val <= pMax:
                newMaxs[dim] = pr.maxs[dim]  # restore
                newMins[dim] = max(pMin, val + 1)
                result += PartRange(mins: newMins, maxs: newMaxs).finalApply(sp[1])
        else:
            raise newException(ValueError, &"Something weird with {sp} for {pr}")


            
proc test2() =
    let (x1wfs, _) = x1.parseInput
    let x1ps = x1wfs.apply2(AllPart)
    echo x1ps
    assert x1ps == 167409079868000

test2()

proc final2() =
    let (wfs, _) = file.parseInput
    let fr2 = wfs.apply2(AllPart)
    assert fr2 == 122112157518711
    echo fr2

final2()