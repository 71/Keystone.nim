import unittest, ../src/keystone

template createEngine(engine: untyped, arch, mode) =
  let engine = newEngine(arch, mode)

  defer:
    engine.close()


suite "keystone tests":

  test "create engine":
    newEngine(Architecture.X86, Mode.b64).close()

  test "emit code":
    createEngine(engine, Architecture.X86, Mode.b32)

    check(engine.assemble("add eax, eax").buf == @[ 0x01u8, 0xc0u8 ])

  test "emit code into buffer":
    createEngine(engine, Architecture.X86, Mode.b32)

    var buf = newSeqOfCap[byte](0)

    engine.assemble("add eax, eax", buf)
    engine.assemble("ret", buf)

    check(buf == @[ 0x01u8, 0xc0u8, 0xc3u8 ])

  test "emit code with dot operator":
    createEngine(engine, Architecture.X86, Mode.b32)

    check(engine.add("eax", "eax").buf == @[ 0x01u8, 0xc0u8 ])
    check(engine.ret.buf == @[ 0xc3u8 ])

    var buf = newSeqOfCap[byte](0)

    engine.add(buf, "eax", "eax")
    engine.ret(buf)

    check(buf == @[ 0x01u8, 0xc0u8, 0xc3u8 ])

  test "emit code with macro":
    createEngine(engine, Architecture.X86, Mode.b32)

    var b1 = newSeqOfCap[byte](64)

    assembly engine, b1:
      add eax, eax
      ret

    check(b1 == @[ 0x01u8, 0xc0u8, 0xc3u8 ])

    let b2 = assembly engine:
      add eax, eax
      ret

    check(b2 == @[ 0x01u8, 0xc0u8, 0xc3u8 ])


  test "raise error on invalid code":
    createEngine(engine, Architecture.X86, Mode.b32)

    expect(KeystoneError):
      discard engine.assemble("ad eax, eax")

  test "built-in constructors":
    newX86Engine().close()
    newX64Engine().close()
    newARMEngine().close()
    newThumbEngine().close()

    if false:
      newARMv8Engine().close()
      newThumbv8Engine().close()

    newARM64Engine().close()
    newMips32Engine().close()
    newMips64Engine().close()
    newPpc32beEngine().close()
    newPpc64beEngine().close()
    newPpc64Engine().close()
    newSparc32Engine().close()
    newSparc64beEngine().close()

    if false:
      newEVMEngine().close()

    newHexagonEngine().close()
    newSystemzEngine().close()
