import std/enumerate
import std/sequtils
import std/strutils
import std/strformat

proc calibration(s: string): int =
    for line in s.splitLines:
        var digits: seq[int]
        for i, c in enumerate(line):
            if c.isDigit:
                digits.add(ord(c) - ord('0'))
            else:
                for j, num in enumerate(@["one", "two", "three",
                        "four", "five",
                        "six", "seven", "eight", "nine"]):
                    if num == line[i .. min(line.len, i +
                                    num.len) - 1]:
                        digits.add(j + 1)
        if len(digits) > 0:
            result += digits[0] * 10 + digits[^1]

assert calibration("""
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
""") == 142

# assert calibration("""
let part2 = """
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
"""
let expected2 = @[29, 83, 13, 24, 42, 14, 76]
let tests2 = zip(part2.splitLines, expected2)
for (line, expected) in tests2:
    let actual = calibration(line)
    echo fmt"{line} - {expected} - {actual}"
    assert calibration(line) == expected

assert calibration(part2) == 281
let entireFile = readFile("input.txt")
# echo entireFile
echo calibration(entireFile)
