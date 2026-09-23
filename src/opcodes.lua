local Opcodes = {}

-- Opcode numbering follows enum LuauOpcode.
-- opmode (informal classification for convenience):
--   0 = no operands
--   1 = A only
--   2 = A B
--   3 = A B C
--   4 = A D (or A E)
--   5 = E (24-bit)
-- kmode: constant kind used by the operand (0 = none, 1 = string, 2 = number,
--        3 = any/table, 4 = import, 5 = jumpx-eq, 6 = jumpx-eq num/str,
--        7 = reverse-K, 8 = forloop aux)
Opcodes.list = {
  [0]  = {name="NOP",             opmode=0, kmode=0, aux=false},
  [1]  = {name="BREAK",           opmode=0, kmode=0, aux=false},
  [2]  = {name="LOADNIL",         opmode=1, kmode=0, aux=false},
  [3]  = {name="LOADB",           opmode=3, kmode=0, aux=false},
  [4]  = {name="LOADN",           opmode=4, kmode=0, aux=false},
  [5]  = {name="LOADK",           opmode=4, kmode=3, aux=false},
  [6]  = {name="MOVE",            opmode=2, kmode=0, aux=false},
  [7]  = {name="GETGLOBAL",       opmode=1, kmode=1, aux=true},
  [8]  = {name="SETGLOBAL",       opmode=1, kmode=1, aux=true},
  [9]  = {name="GETUPVAL",        opmode=2, kmode=0, aux=false},
  [10] = {name="SETUPVAL",        opmode=2, kmode=0, aux=false},
  [11] = {name="CLOSEUPVALS",     opmode=1, kmode=0, aux=false},
  [12] = {name="GETIMPORT",       opmode=4, kmode=4, aux=true},
  [13] = {name="GETTABLE",        opmode=3, kmode=0, aux=false},
  [14] = {name="SETTABLE",        opmode=3, kmode=0, aux=false},
  [15] = {name="GETTABLEKS",      opmode=3, kmode=1, aux=true},
  [16] = {name="SETTABLEKS",      opmode=3, kmode=1, aux=true},
  [17] = {name="GETTABLEN",       opmode=3, kmode=0, aux=false},
  [18] = {name="SETTABLEN",       opmode=3, kmode=0, aux=false},
  [19] = {name="NEWCLOSURE",      opmode=4, kmode=0, aux=false},
  [20] = {name="NAMECALL",        opmode=3, kmode=1, aux=true},
  [21] = {name="CALL",            opmode=3, kmode=0, aux=false},
  [22] = {name="RETURN",          opmode=2, kmode=0, aux=false},
  [23] = {name="JUMP",            opmode=4, kmode=0, aux=false},
  [24] = {name="JUMPBACK",        opmode=4, kmode=0, aux=false},
  [25] = {name="JUMPIF",          opmode=4, kmode=0, aux=false},
  [26] = {name="JUMPIFNOT",       opmode=4, kmode=0, aux=false},
  [27] = {name="JUMPIFEQ",        opmode=4, kmode=0, aux=true},
  [28] = {name="JUMPIFLE",        opmode=4, kmode=0, aux=true},
  [29] = {name="JUMPIFLT",        opmode=4, kmode=0, aux=true},
  [30] = {name="JUMPIFNOTEQ",     opmode=4, kmode=0, aux=true},
  [31] = {name="JUMPIFNOTLE",     opmode=4, kmode=0, aux=true},
  [32] = {name="JUMPIFNOTLT",     opmode=4, kmode=0, aux=true},
  [33] = {name="ADD",             opmode=3, kmode=0, aux=false},
  [34] = {name="SUB",             opmode=3, kmode=0, aux=false},
  [35] = {name="MUL",             opmode=3, kmode=0, aux=false},
  [36] = {name="DIV",             opmode=3, kmode=0, aux=false},
  [37] = {name="MOD",             opmode=3, kmode=0, aux=false},
  [38] = {name="POW",             opmode=3, kmode=0, aux=false},
  [39] = {name="ADDK",            opmode=3, kmode=2, aux=false},
  [40] = {name="SUBK",            opmode=3, kmode=2, aux=false},
  [41] = {name="MULK",            opmode=3, kmode=2, aux=false},
  [42] = {name="DIVK",            opmode=3, kmode=2, aux=false},
  [43] = {name="MODK",            opmode=3, kmode=2, aux=false},
  [44] = {name="POWK",            opmode=3, kmode=2, aux=false},
  [45] = {name="AND",             opmode=3, kmode=0, aux=false},
  [46] = {name="OR",              opmode=3, kmode=0, aux=false},
  [47] = {name="ANDK",            opmode=3, kmode=2, aux=false},
  [48] = {name="ORK",             opmode=3, kmode=2, aux=false},
  [49] = {name="CONCAT",          opmode=3, kmode=0, aux=false},
  [50] = {name="NOT",             opmode=2, kmode=0, aux=false},
  [51] = {name="MINUS",           opmode=2, kmode=0, aux=false},
  [52] = {name="LENGTH",          opmode=2, kmode=0, aux=false},
  [53] = {name="NEWTABLE",        opmode=2, kmode=0, aux=true},
  [54] = {name="DUPTABLE",        opmode=4, kmode=3, aux=false},
  [55] = {name="SETLIST",         opmode=3, kmode=0, aux=true},
  [56] = {name="FORNPREP",        opmode=4, kmode=0, aux=false},
  [57] = {name="FORNLOOP",        opmode=4, kmode=0, aux=false},
  [58] = {name="FORGLOOP",        opmode=4, kmode=8, aux=true},
  [59] = {name="FORGPREP_INEXT",  opmode=4, kmode=0, aux=false},
  [60] = {name="FASTCALL3",       opmode=3, kmode=1, aux=true},
  [61] = {name="FORGPREP_NEXT",   opmode=4, kmode=0, aux=false},
  [62] = {name="NATIVECALL",      opmode=0, kmode=0, aux=false},
  [63] = {name="GETVARARGS",      opmode=2, kmode=0, aux=false},
  [64] = {name="DUPCLOSURE",      opmode=4, kmode=3, aux=false},
  [65] = {name="PREPVARARGS",     opmode=1, kmode=0, aux=false},
  [66] = {name="LOADKX",          opmode=1, kmode=1, aux=true},
  [67] = {name="JUMPX",           opmode=5, kmode=0, aux=false},
  [68] = {name="FASTCALL",        opmode=3, kmode=0, aux=false},
  [69] = {name="COVERAGE",        opmode=5, kmode=0, aux=false},
  [70] = {name="CAPTURE",         opmode=2, kmode=0, aux=false},
  [71] = {name="SUBRK",           opmode=3, kmode=7, aux=false},
  [72] = {name="DIVRK",           opmode=3, kmode=7, aux=false},
  [73] = {name="FASTCALL1",       opmode=3, kmode=0, aux=false},
  [74] = {name="FASTCALL2",       opmode=3, kmode=0, aux=true},
  [75] = {name="FASTCALL2K",      opmode=3, kmode=1, aux=true},
  [76] = {name="FORGPREP",        opmode=4, kmode=0, aux=false},
  [77] = {name="JUMPXEQKNIL",     opmode=4, kmode=5, aux=true},
  [78] = {name="JUMPXEQKB",       opmode=4, kmode=5, aux=true},
  [79] = {name="JUMPXEQKN",       opmode=4, kmode=6, aux=true},
  [80] = {name="JUMPXEQKS",       opmode=4, kmode=6, aux=true},
  [81] = {name="IDIV",            opmode=3, kmode=0, aux=false},
  [82] = {name="IDIVK",           opmode=3, kmode=2, aux=false},
  [83] = {name="GETUDATAKS",      opmode=3, kmode=1, aux=true},
  [84] = {name="SETUDATAKS",      opmode=3, kmode=1, aux=true},
  [85] = {name="NAMECALLUDATA",   opmode=3, kmode=1, aux=true},
  [86] = {name="NEWCLASSMEMBER",  opmode=3, kmode=1, aux=true},
  [87] = {name="CALLFB",          opmode=3, kmode=0, aux=true},
  [88] = {name="CMPPROTO",        opmode=4, kmode=0, aux=true},
  [89] = {name="FASTPCALL",       opmode=3, kmode=0, aux=false},
  [90] = {name="NEWCLASS",        opmode=3, kmode=1, aux=true},
}

Opcodes.count = 91

-- Sets for O(1) lookups by name.
Opcodes.jumpSet = {}
Opcodes.loopJumpSet = {}
Opcodes.fastCallSet = {}
Opcodes.skipCSet = {}

local jumpNames = {
  "JUMP", "JUMPBACK", "JUMPIF", "JUMPIFNOT",
  "JUMPIFEQ", "JUMPIFLE", "JUMPIFLT", "JUMPIFNOTEQ",
  "JUMPIFNOTLE", "JUMPIFNOTLT",
  "JUMPX", "JUMPXEQKNIL", "JUMPXEQKB", "JUMPXEQKN", "JUMPXEQKS",
  "FORNPREP", "FORNLOOP", "FORGPREP", "FORGLOOP",
  "FORGPREP_INEXT", "FORGPREP_NEXT",
  "CMPPROTO",
}

local loopJumpNames = { "JUMPBACK", "FORNLOOP", "FORGLOOP" }

local fastCallNames = {
  "FASTCALL", "FASTCALL1", "FASTCALL2", "FASTCALL2K", "FASTCALL3", "FASTPCALL",
}

-- Opcodes where operand C can act as a short skip (LOADB uses C as jump offset).
local skipCNames = { "LOADB" }

for _, n in ipairs(jumpNames) do Opcodes.jumpSet[n] = true end
for _, n in ipairs(loopJumpNames) do Opcodes.loopJumpSet[n] = true end
for _, n in ipairs(fastCallNames) do Opcodes.fastCallSet[n] = true end
for _, n in ipairs(skipCNames) do Opcodes.skipCSet[n] = true end

function Opcodes.get(op)
  return Opcodes.list[op]
end

function Opcodes.byName(name)
  for i = 0, Opcodes.count - 1 do
    local info = Opcodes.list[i]
    if info and info.name == name then return info, i end
  end
  return nil, nil
end

function Opcodes.isAux(op)
  local info = Opcodes.list[op]
  return info ~= nil and info.aux == true
end

function Opcodes.getOpLength(op)
  if Opcodes.isAux(op) then return 2 end
  return 1
end

function Opcodes.getName(op)
  local info = Opcodes.list[op]
  return info and info.name or ("UNKNOWN_%d"):format(op)
end

function Opcodes.isJump(op)
  local info = Opcodes.list[op]
  return info ~= nil and Opcodes.jumpSet[info.name] == true
end

function Opcodes.isLoopJump(op)
  local info = Opcodes.list[op]
  return info ~= nil and Opcodes.loopJumpSet[info.name] == true
end

function Opcodes.isFastCall(op)
  local info = Opcodes.list[op]
  return info ~= nil and Opcodes.fastCallSet[info.name] == true
end

function Opcodes.isSkipC(op)
  local info = Opcodes.list[op]
  return info ~= nil and Opcodes.skipCSet[info.name] == true
end

-- Returns true if execution falls through to the next instruction.
-- Unconditional JUMP/JUMPBACK/JUMPX and RETURN do not fall through.
-- CMPPROTO falls through because it is a conditional jump.
function Opcodes.isFallthrough(op)
  local info = Opcodes.list[op]
  if not info then return true end
  local n = info.name
  if n == "RETURN" or n == "JUMP" or n == "JUMPBACK" or n == "JUMPX" then
    return false
  end
  return true
end

-- Inverse conditional mapping (used by the decompiler).
Opcodes.inverseCondition = {
  JUMPIF = "JUMPIFNOT",
  JUMPIFNOT = "JUMPIF",
  JUMPIFEQ = "JUMPIFNOTEQ",
  JUMPIFNOTEQ = "JUMPIFEQ",
  JUMPIFLE = "JUMPIFNOTLE",
  JUMPIFNOTLE = "JUMPIFLE",
  JUMPIFLT = "JUMPIFNOTLT",
  JUMPIFNOTLT = "JUMPIFLT",
  JUMPXEQKNIL = "JUMPXEQKNIL",
  JUMPXEQKB = "JUMPXEQKB",
  JUMPXEQKN = "JUMPXEQKN",
  JUMPXEQKS = "JUMPXEQKS",
}

return Opcodes
