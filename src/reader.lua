local Reader = {}
Reader.__index = Reader

function Reader.new(data)
    return setmetatable({
        data = data,
        pos = 1,
    }, Reader)
end

function Reader:readByte()
    local b = string.byte(self.data, self.pos)
    self.pos = self.pos + 1
    return b
end

function Reader:readUInt32()
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
    end
    return result
end

function Reader:readVarInt64()
    local result = 0
    local shift = 0
    while true do
        local b = self:readByte()
        result = result + (b % 128) * (2 ^ shift)
        if b < 128 then break end
        shift = shift + 7
        if shift > 63 then break end
    end
    return result
end

function Reader:readString()
    local len = self:readVarInt()
    local str = string.sub(self.data, self.pos, self.pos + len - 1)
    self.pos = self.pos + len
    return str
end

function Reader:readFloat()
    local buf = buffer.fromstring(self.data)
    local f = buffer.readf32(buf, self.pos - 1)
    self.pos = self.pos + 4
    return f
end

function Reader:readDouble()
    local buf = buffer.fromstring(self.data)
    local d = buffer.readf64(buf, self.pos - 1)
    self.pos = self.pos + 8
    return d
end

return Reader
