import strutils

when defined(windows):
  const libname = "keystone.dll"
else:
  const libname = "libkeystone.so"
{.pragma: ks, cdecl, importc, dynlib: libname.}


type

  ## Architecture.
  Architecture* {.pure.} = enum
    ARM = 1,          ##  ARM architecture (including Thumb, Thumb-2).
    ARM64,            ##  ARM-64, also called AArch64.
    MIPS,             ##  Mips architecture.
    X86,              ##  X86 architecture (including x86 & x86-64).
    PPC,              ##  PowerPC architecture (currently unsupported).
    SPARC,            ##  Sparc architecture.
    SYSTEMZ,          ##  SystemZ architecture (S390X).
    HEXAGON,          ##  Hexagon architecture.
    EVM               ##  Ethereum Virtual Machine architecture.

  ## Keystone error code.
  KeystoneErrorCode* {.pure.} = enum
    OK = 0,            ##  No error: everything was fine
    NOMEM,             ##  Out-Of-Memory error: ks_open(), ks_emulate()
    ARCH,              ##  Unsupported architecture: ks_open()
    HANDLE,            ##  Invalid handle
    MODE,              ##  Invalid/unsupported mode: ks_open()
    VERSION,           ##  Unsupported version (bindings)
    OPT_INVALID,       ##  Unsupported option

    EXPR_TOKEN = 128, ##  unknown token in expression
    DIRECTIVE_VALUE_RANGE, ##  literal value out of range for directive
    DIRECTIVE_ID,  ##  expected identifier in directive
    DIRECTIVE_TOKEN, ##  unexpected token in directive
    DIRECTIVE_STR, ##  expected string in directive
    DIRECTIVE_COMMA, ##  expected comma in directive
    DIRECTIVE_RELOC_NAME, ##  expected relocation name in directive
    DIRECTIVE_RELOC_TOKEN, ##  unexpected token in .reloc directive
    DIRECTIVE_FPOINT, ##  invalid floating point in directive
    DIRECTIVE_UNKNOWN, ##  unknown directive
    DIRECTIVE_EQU, ##  invalid equal directive
    DIRECTIVE_INVALID, ##  (generic) invalid directive
    VARIANT_INVALID, ##  invalid variant
    EXPR_BRACKET,  ##  brackets expression not supported on this target
    SYMBOL_MODIFIER, ##  unexpected symbol modifier following '@'
    SYMBOL_REDEFINED, ##  invalid symbol redefinition
    SYMBOL_MISSING, ##  cannot find a symbol
    RPAREN,        ##  expected ')' in parentheses expression
    STAT_TOKEN,    ##  unexpected token at start of statement
    UNSUPPORTED,   ##  unsupported token yet
    MACRO_TOKEN,   ##  unexpected token in macro instantiation
    MACRO_PAREN,   ##  unbalanced parentheses in macro argument
    MACRO_EQU,     ##  expected '=' after formal parameter identifier
    MACRO_ARGS,    ##  too many positional arguments
    MACRO_LEVELS_EXCEED, ##  macros cannot be nested more than 20 levels deep
    MACRO_STR,     ##  invalid macro string
    MACRO_INVALID, ##  invalid macro (generic error)
    ESC_BACKSLASH, ##  unexpected backslash at end of escaped string
    ESC_OCTAL,     ##  invalid octal escape sequence  (out of range)
    ESC_SEQUENCE,  ##  invalid escape sequence (unrecognized character)
    ESC_STR,       ##  broken escape string
    TOKEN_INVALID, ##  invalid token
    INSN_UNSUPPORTED, ##  this instruction is unsupported in this mode
    FIXUP_INVALID, ##  invalid fixup
    LABEL_INVALID, ##  invalid label
    FRAGMENT_INVALID, ##  invalid fragment
                                ##  generic input assembly errors - architecture specific
    INVALIDOPERAND = 512,
    MISSINGFEATURE,
    MNEMONICFAIL

  KeystoneError* = object of CatchableError
    code*: KeystoneErrorCode

  ##  Runtime option for the Keystone engine
  OptionType* {.pure.} = enum
    SYNTAX = 1,        ##  Choose syntax for input assembly.
    SYM_RESOLVER       ##  Set symbol resolver callback.

  ##  Runtime option value.
  SyntaxOption* {.pure.} = enum
    INTEL = 1 shl 0,  ##  X86 Intel syntax - default on X86 (KS_OPT_SYNTAX).
    ATT = 1 shl 1,    ##  X86 ATT asm syntax (KS_OPT_SYNTAX).
    NASM = 1 shl 2,   ##  X86 Nasm syntax (KS_OPT_SYNTAX).
    MASM = 1 shl 3,   ##  X86 Masm syntax (KS_OPT_SYNTAX) - unsupported yet.
    GAS = 1 shl 4,    ##  X86 GNU GAS syntax (KS_OPT_SYNTAX).
    RADIX16 = 1 shl 5 ##  All immediates are in hex format (i.e 12 is 0x12).

  ##  Resolver callback to provide value for a missing symbol in @symbol.
  ##  To handle a symbol, the resolver must put value of the symbol in @value,
  ##  then returns True.
  SymbolResolver* = proc (symbol: cstring; value: ptr csize_t): bool {.cdecl.}

  ## Reference to a Keystone engine.
  Engine* = pointer

  ## Encoded instuction(s).
  EncodedData* = tuple[buf: seq[byte], size: int, statementsCount: int]


## Mode.
type Mode* = distinct uint

##  Little-endian mode (default).
template littleEndian*(m: type Mode): Mode = 0.Mode
##  16-bit mode.
template b16*(m: type Mode): Mode = (1 shl 1).Mode
##  32-bit mode.
template b32*(m: type Mode): Mode = (1 shl 2).Mode
##  64-bit mode.
template b64*(m: type Mode): Mode = (1 shl 3).Mode
##  Big-endian mode.
template bigEndian*(m: type Mode): Mode = (1 shl 30).Mode
## ARM mode.
template arm*(m: type Mode): Mode = (1 shl 0).Mode
## ARM64 mode.
template arm64*(m: type Mode): Mode = (1 shl 3).Mode
## Thumb mode.
template thumb*(m: type Mode): Mode = (1 shl 4).Mode
## V8 mode.
template v8*(m: type Mode): Mode = (1 shl 6).Mode
## MicroMips mode.
template micro*(m: type Mode): Mode = (1 shl 4).Mode
## Mips III mode.
template mips3*(m: type Mode): Mode = (1 shl 5).Mode
## Mips32r6 mode.
template mips32r6*(m: type Mode): Mode = (1 shl 6).Mode
## Mips32 mode.
template mips32*(m: type Mode): Mode = (1 shl 2).Mode
## Mips64 mode.
template mips64*(m: type Mode): Mode = (1 shl 3).Mode
## PPC32 mode.
template ppc32*(m: type Mode): Mode = (1 shl 2).Mode
## PPC64 mode.
template ppc64*(m: type Mode): Mode = (1 shl 3).Mode
## Quad Processing eXtensions mode.
template qpx*(m: type Mode): Mode = (1 shl 4).Mode
## Sparc32 mode.
template sparc32*(m: type Mode): Mode = (1 shl 2).Mode
## Sparc64 mode.
template sparc64*(m: type Mode): Mode = (1 shl 3).Mode
## SparcV9 mode.
template v9*(m: type Mode): Mode = (1 shl 4).Mode

proc `or`*(a, b: Mode): Mode {.inline.} =
  (a.uint or b.uint).Mode



proc ks_version(major: ptr cuint; minor: ptr cuint): cuint {.ks.}
proc ks_arch_supported(arch: Architecture): bool {.ks.}
proc ks_open(arch: Architecture; mode: Mode; ks: ptr Engine): KeystoneErrorCode {.ks.}
proc ks_close(ks: Engine): KeystoneErrorCode {.ks.}
proc ks_errno(ks: Engine): KeystoneErrorCode {.ks.}
proc ks_strerror(code: KeystoneErrorCode): cstring {.ks.}
proc ks_option(ks: Engine; ty: OptionType; value: csize_t): KeystoneErrorCode {.ks.}
proc ks_asm(ks: Engine; toasm: cstring; address: uint64;
            encoding: ptr ptr byte; encoding_size: ptr csize_t; stat_count: ptr csize_t): cint {.ks.}
proc ks_free(p: ptr byte) {.ks.}

proc `$`*(err: KeystoneErrorCode): string {.inline.} =
  ## Returns a string representation of the given error code.
  $ks_strerror(err)

template raiseIfNeeded(err: KeystoneErrorCode) =
  if err != KeystoneErrorCode.OK:
    let exn = newException(KeystoneError, $err)
    exn.code = err
    raise exn

proc keystoneVersion*(): (int, int, int) {.inline.} =
  ## Returns the version of the Keystone library as a (major, minor, extra) tuple.
  var major, minor: cuint
  let v = ks_version(addr major, addr minor)

  (major.int, minor.int, v.int)

proc isSupported*(arch: Architecture): bool {.inline.} =
  ## Returns whether the specified architecture is supported by Keystone.
  ks_arch_supported(arch)

proc `syntaxOption=`*(engine: Engine, val: SyntaxOption) {.inline.} =
  ## Sets the syntax options of the engine.
  discard ks_option(engine, OptionType.SYNTAX, val.csize_t)

proc `symbolResolver=`*(engine: Engine, resolver: SymbolResolver) {.inline.} =
  ## Sets the symbol resulver used by the engine.
  discard ks_option(engine, OptionType.SYM_RESOLVER, cast[csize_t](resolver))

proc newEngine*(arch: Architecture, mode: Mode): Engine {.inline.} =
  ## Creates a new Keystone engine.
  ks_open(arch, mode, addr result).raiseIfNeeded()

proc close*(engine: Engine) {.inline.} =
  ## Destroys the engine.
  ks_close(engine).raiseIfNeeded()

proc lastErrorCode*(engine: Engine): KeystoneErrorCode {.inline.} =
  ## Returns the last returned error code.
  ks_errno(engine)

proc assemble*(engine: Engine, str: string, address: uint64 = 0): EncodedData {.inline.} =
  ## Encodes the given string through the given engine.
  var
    enc: ptr byte
    size: csize_t
    stmts: csize_t

  let r = ks_asm(engine, str.cstring, address, addr enc, addr size, addr stmts)

  if r == -1:
    engine.lastErrorCode.raiseIfNeeded()

  var encoded = newSeqUninitialized[byte](size)

  copyMem(addr encoded[0], enc, size)
  ks_free(enc)

  (encoded, size.int, stmts.int)

proc assemble*(engine: Engine, str: string, buffer: var seq[byte], address: uint64 = 0) {.inline.} =
  ## Encodes the given string through the given engine into the given buffer.
  var
    enc: ptr byte
    size: csize_t
    stmts: csize_t

  let r = ks_asm(engine, str.cstring, address, addr enc, addr size, addr stmts)

  if r == -1:
    engine.lastErrorCode.raiseIfNeeded()

  let e = cast[csize_t](enc)

  for i in 0..size-1:
    buffer.add(cast[ptr byte](e + i)[])

  ks_free(enc)


template ctor(name, arch, mode) =
  proc name*(): Engine {.inline.} =
    ## Creates a new Keystone engine using the chosen architecture.
    ks_open(arch, mode, addr result).raiseIfNeeded()

ctor(newX86Engine,       Architecture.X86, Mode.b32)
ctor(newX64Engine,       Architecture.X86, Mode.b64)
ctor(newARMEngine,       Architecture.ARM, Mode.arm)
ctor(newThumbEngine,     Architecture.ARM, Mode.thumb)
ctor(newARMv8Engine,     Architecture.ARM, Mode.v8 or Mode.arm)
ctor(newThumbv8Engine,   Architecture.ARM, Mode.v8 or Mode.thumb)
ctor(newARM64Engine,     Architecture.ARM64, Mode.littleEndian)
ctor(newMips32Engine,    Architecture.MIPS, Mode.mips32)
ctor(newMips64Engine,    Architecture.MIPS, Mode.mips64)
ctor(newPpc32beEngine,   Architecture.PPC, Mode.ppc32 or Mode.bigEndian)
ctor(newPpc64beEngine,   Architecture.PPC, Mode.ppc64 or Mode.bigEndian)
ctor(newPpc64Engine,     Architecture.PPC, Mode.ppc64)
ctor(newSparc32Engine,   Architecture.SPARC, Mode.sparc32)
ctor(newSparc64beEngine, Architecture.SPARC, Mode.sparc64 or Mode.bigEndian)
ctor(newEVMEngine,       Architecture.EVM, Mode.littleEndian)
ctor(newHexagonEngine,   Architecture.HEXAGON, Mode.littleEndian)
ctor(newSystemzEngine,   Architecture.SYSTEMZ, Mode.littleEndian)

template `.`*(engine: Engine, opcode: untyped): EncodedData =
  engine.assemble(astToStr(opcode))

template `.()`*(engine: Engine, opcode: untyped, buf: seq[byte], args: varargs[string]) =
  engine.assemble(astToStr(opcode) & " " & args.join(", "), buf)

template `.()`*(engine: Engine, opcode: untyped, args: varargs[string]): EncodedData =
  engine.assemble(astToStr(opcode) & " " & args.join(", "))


import macros

macro assembly*(engine: Engine, args: varargs[untyped]): untyped =
  if args.len == 0:
    error("An assembly body must be provided.")
  elif args.len > 2:
    error("Only two arguments can be provided.")

  let addBuf = args.len == 1
  let body = if addBuf: args[0] else: args[1]

  expectKind(body, nnkStmtList)

  result = newNimNode(nnkStmtList, body)

  let buf =
    if addBuf: genSym(nskVar, "buf")
    else: args[0]

  if addBuf:
    result.add quote do:
      var `buf` = newSeqOfCap[byte](64)

  for s in body:
    case s.kind
    of nnkCommentStmt:
      continue
    of nnkCommand, nnkIdent:
      let ins = s.toStrLit

      result.add quote do:
        `engine`.assemble(`ins`, `buf`)
    else:
      error("Unknown assembly syntax.", s)

  if addBuf:
    result.add buf
