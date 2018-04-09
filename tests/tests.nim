import unittest, ../src/keystone

template createEngine(engine: untyped, arch, mode) =
  let engine = newEngine(arch, mode)

  defer:
    engine.closeEngine()


suite "keystone tests":

  test "create engine":
    newEngine(Architecture.X86, Mode.b64).closeEngine()

  test "emit code":
    createEngine(engine, Architecture.X86, Mode.b32)

    check(engine.assemble("add eax, eax").buf == @[ 0x01u8, 0xc0u8 ])

  test "emit code into buffer":
    createEngine(engine, Architecture.X86, Mode.b32)

    var buf = newSeqOfCap[byte](0)

    engine.assemble("add eax, eax", buf)
    engine.assemble("ret", buf)

    check(buf == @[ 0x01u8, 0xc0u8, 0xc3u8 ])

  test "emit code with template":
    createEngine(engine, Architecture.X86, Mode.b32)

    check(engine.add("eax", "eax").buf == @[ 0x01u8, 0xc0u8 ])
    check(engine.ret.buf == @[ 0xc3u8 ])

    var buf = newSeqOfCap[byte](0)

    engine.add(buf, "eax", "eax")
    engine.ret(buf)

    check(buf == @[ 0x01u8, 0xc0u8, 0xc3u8 ])

  test "raise error on invalid code":
    createEngine(engine, Architecture.X86, Mode.b32)

    expect(KeystoneError):
      discard engine.assemble("ad eax, eax")

  test "built-in constructors":
    newX86Engine().closeEngine()
    newX64Engine().closeEngine()
    newARMEngine().closeEngine()
    newThumbEngine().closeEngine()

    if false:
      newARMv8Engine().closeEngine()
      newThumbv8Engine().closeEngine()

    newARM64Engine().closeEngine()
    newMips32Engine().closeEngine()
    newMips64Engine().closeEngine()
    newPpc32beEngine().closeEngine()
    newPpc64beEngine().closeEngine()
    newPpc64Engine().closeEngine()
    newSparc32Engine().closeEngine()
    newSparc64beEngine().closeEngine()

    if false:
      newEVMEngine().closeEngine()
    
    newHexagonEngine().closeEngine()
    newSystemzEngine().closeEngine()
