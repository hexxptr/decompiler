local baseUrl = "https://raw.githubusercontent.com/hexxptr/decompiler/main/src/"

local Reader = loadstring(game:HttpGet(baseUrl .. "reader.lua"))()
local Opcodes = loadstring(game:HttpGet(baseUrl .. "opcodes.lua"))()

local Deserializer = {}

local function deserialize(bytecode)
    local reader = Reader.new(bytecode)
    
    -- Version
    local version = reader:readByte()
    if version == 0 then
        error("bytecode is an error message")
    end
    if version < 3 or version > 14 then
        error("unsupported version: " .. version)
    end
    
    -- Types version
    local typesVersion = 0
    if version >= 4 then
        typesVersion = reader:readByte()
    end
    
    -- String table
    local stringCount = reader:readVarInt()
    local strings = {}
    for i = 1, stringCount do
        strings[i] = reader:readString()
    end
    
    print("Version:", version)
    print("Types version:", typesVersion)
    print("String count:", stringCount)
    print("First string:", strings[1])
    print("Last string:", strings[stringCount])
    
    return {
        version = version,
        typesVersion = typesVersion,
        strings = strings,
        protos = {},
        main = nil,
    }
end

Deserializer.deserialize = deserialize

return Deserializer
