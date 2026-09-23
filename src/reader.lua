-- Binary reader for Luau bytecode with automatic position tracking.

local Reader = {}
Reader.__index = Reader

function Reader.new(data)
  return setmetatable({
    data = data,
    buf = buffer.fromstring(data),
    pos = 1,
  }, Reader)
end

function Reader:remaining()
  return #self.data - self.pos + 1
end

function Reader:ensure(n)
  if self.pos + n - 1 > #self.data then
    error(("reader: out of bounds at pos %d, need %d bytes, have %d")
      :format(self.pos, n, self:remaining()), 2)
  end
end

function Reader:readByte()
  local b = string.byte(self.data, self.pos)
  if not b then
    error(("reader: unexpected EOF at pos %d"):format(self.pos), 2)
  end
  self.pos = self.pos + 1
  return b
end

function Reader:readUInt8()
  return self:readByte()
end

function Reader:readInt8()
  local b = self:readByte()
  if b >= 0x80 then b = b - 0x100 end
  return b
end

function Reader:readBool()
  return self:readByte() ~= 0
end

function Reader:readUInt16()
  self:ensure(2)
  local b1, b2 = string.byte(self.data, self.pos, self.pos + 1)
  self.pos = self.pos + 2
  return b1 + b2 * 256
end

function Reader:readUInt32()
  self:ensure(4)
  local b1, b2, b3, b4 = string.byte(self.data, self.pos, self.pos + 3)
  self.pos = self.pos + 4
  return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

function Reader:readInt32()
  local v = self:readUInt32()
  if v >= 0x80000000 then
    v = v - 0x100000000
  end
  return v
end

function Reader:readVarInt()
  local result = 0
  local shift = 0
  while true do
    local b = self:readByte()
    result = result + (b % 128) * (2 ^ shift)
    if b < 128 then break end
    shift = shift + 7
    if shift > 63 then
      error(("reader: varint too long at pos %d"):format(self.pos), 2)
    end
  end
  return result
end

function Reader:readVarInt64()
  -- For 64-bit values use bit-precise reconstruction via 32-bit halves,
  -- since Lua numbers cannot represent all 64-bit integers exactly.
  local low = 0
  local high = 0
  local shift = 0
  while true do
    local b = self:readByte()
    local chunk = b % 128
    if shift < 32 then
      low = low + chunk * (2 ^ shift)
    else
      high = high + chunk * (2 ^ (shift - 32))
    end
    if b < 128 then break end
    shift = shift + 7
    if shift > 63 then
      error(("reader: varint64 too long at pos %d"):format(self.pos), 2)
    end
  end
  return high, low
end

function Reader:readFloat()
  local f = buffer.readf32(self.buf, self.pos - 1)
  self.pos = self.pos + 4
  return f
end

function Reader:readDouble()
  local d = buffer.readf64(self.buf, self.pos - 1)
  self.pos = self.pos + 8
  return d
end

function Reader:readBytes(n)
  self:ensure(n)
  local s = string.sub(self.data, self.pos, self.pos + n - 1)
  self.pos = self.pos + n
  return s
end

-- Reads a length-prefixed string (varint length + bytes).
function Reader:readString()
  local len = self:readVarInt()
  return self:readBytes(len)
end

function Reader:skip(n)
  self:ensure(n)
  self.pos = self.pos + n
end

function Reader:seek(pos)
  if pos < 1 or pos > #self.data + 1 then
    error(("reader: seek out of range: %d"):format(pos), 2)
  end
  self.pos = pos
end

return Reader
