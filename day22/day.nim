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

type Dir = enum
    L, U, R, D

const QDir = {L, U, R, D}

proc flip(dir: Dir) : Dir =  # /
    {L: D, R: U, D: L, U: R}.toTable[dir] 

proc flop(dir: Dir) : Dir =  # \
    {L: U, R: D, D: R, U: L}.toTable[dir] 

proc `-`(dir: Dir) : Dir =
    {L: R, R: L, D: U, U: D}.toTable[dir]

type Pos = (int, int)

proc `*`(factor: int, dir: Dir) : Pos =
        result[0] = {U: -factor, D: factor}.toTable.getOrDefault(dir, 0)
        result[1] = {L: -factor, R: factor}.toTable.getOrDefault(dir, 0)

proc `+`(lhs, rhs: Pos) : Pos =
    result[0] = lhs[0] + rhs[0]
    result[1] = lhs[1] + rhs[1]

proc `+`(pos: Pos, dir: Dir) : (int, int) =
    result = pos + (1 * dir)

proc `+=`(self: var Pos, dir: Dir)  =
    self = self + (1 * dir)

# for A* see Day 17
# for counts of inner points see Day 18

let x1 = """
"""
proc parseInput(s: string) : Grid =
    result.map = s.splitLines.filterIt(it.len > 0)
    result.height = result.map.len
    result.width = result.map[0].len
    for line in result.map:
        assert line.len == result.width





let file = readFile("input.txt")
# let fp = file.parseInput