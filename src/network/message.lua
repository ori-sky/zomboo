local struct = require "struct"
local proto = require "network/proto"

local message = {}

message.format = "c2I2I2"

function message.new(id, cmd)
	if not cmd then cmd = proto.null end

	local message = {}

	message.id = id
	message.cmd = cmd

	function message:pack()
		return struct.pack("c2I2I2", "ZB", self.id, self.cmd)
	end

	function message:str()
		return "ZB id="..string.format("0x%04x", self.id)..", cmd="..string.format("0x%04x", self.cmd)
	end

	function message:dump()
		print(self:str())
	end

	return message
end

function message.unpack(data)
	local proto, id, cmd = struct.unpack("c2I2I2", data)
	assert(proto == "ZB", "unknown protocol")
	return message.new(id, cmd)
end

return message
