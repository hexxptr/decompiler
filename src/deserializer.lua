local baseUrl = "https://raw.githubusercontent.com/hexxptr/decompiler/main/src/"

local Reader = loadstring(game:HttpGet(baseUrl .. "reader.lua"))()
local Opcodes = loadstring(game:HttpGet(baseUrl .. "opcodes.lua"))()

local Deserializer = {}

local function readConstant()
    return {}
end

local function readProto(reader, strings, version, typesVersion)
    local proto = {}

    if version >= 12 then
      proto.protoSize = reader:readVarInt()
      proto.protoStart = reader.pos
    end

    proto.maxstacksize = reader:readByte()
    proto.numparams = reader:readByte()
    proto.nups = reader:readByte()
    proto.isvararg = reader:readByte()
    proto.flags = reader:readByte()

    local typeSize = reader:readVarInt()
    if typeSize > 0 then
        reader:skip(typeSize)
    end

    local sizecode = reader:readVarInt()
    local code = table.create(sizecode)
    for i = 1, sizecode do
        code[i] = reader:readUInt32()
    end
    proto.sizecode = sizecode
    proto.code = code

    -- TODO: instructions, constants, children, debug info, feedback, cost

    if version >= 12 then
        reader:seek(proto.protoStart + proto.protoSize)
    end

    return proto
end

local function deserialize(bytecode)
    local reader = Reader.new(bytecode)
  
    local version = reader:readByte()
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
  
    -- Userdata remap
    if typesVersion == 3 then
        while true do
            local index = reader:readByte()
            if index == 0 then break end
            local nameRef = reader:readVarInt()
        end
    end
    
    local protoCount = reader:readVarInt()
    local protos = {}
    for i = 1, protoCount do
        protos[i] = readProto(reader, strings, version, typesVersion)
    end

    local mainId = reader:readVarInt()

    return {
        version = version,
        typesVersion = typesVersion,
        strings = strings,
        protos = protos,
        mainId = mainId,
    }
end

Deserializer.deserialize = deserialize

return Deserializer
