Keystone.nim
============

[Nim](https://nim-lang.org/) bindings for the [Keystone](http://www.keystone-engine.org/) assembler.

```nim
# Create engine safely
let engine = newX86Engine()

defer:
  engine.close()

# Emit to tuple
let enc = engine.assemble("add eax, eax ; ret")

assert enc.buf == @[ 0x01, 0xC0, 0xC3 ]
assert enc.size == 3
assert enc.statementsCount == 2

# Emit using dot operator
let enc = engine.add("eax", "eax")

# Emit to buffer now
var buf = newSeqOfCap[byte](0)

engine.assemble("add eax, eax", buf)
engine.ret(buf)

assert buf == @[ 0x01, 0xC0, 0xC3 ]

# No silent errors
try:
  engine.assemble("add 42")
expect KeystoneError:
  echo "Error encountered: ", getCurrentExceptionMsg()
```
