import std/re

echo "12ab34".findAll(re"\d+")

let x = "12ab34".findBounds(re"x+")
echo x
echo x.first

echo "--1--"
for f in "12ab34".findAll(re"\d+"):
    echo f

echo "--2--"
iterator findAllBounds(buf: string; pattern: Regex, start : int = 0): tuple[first, last: int] =
    var b = buf.findBounds(pattern, start=start)
    while b.first != -1:
        yield b
        b = findBounds(buf, pattern, start=b.last + 1)

for f in "12ab34".findAllBounds(re"\d+"):
    echo f