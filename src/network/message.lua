local struct = require "struct"
local proto = require "network/proto"
local types = require "network/types"

local message = {}

message.format = {
	[proto.null]    = {},
	[proto.hello]   = {},
	[proto.goodbye] = {},
	[proto.setx]    = {types.f32}
}

function message.new(id, cmd, ...)
	if not cmd then cmd = proto.null end

	local msg = {}

	msg.id = id
	msg.cmd = cmd
	msg.args = {...}

	function msg:pack()
		local fmt = "c2I2I2"

		for k, v in ipairs(message.format[self.cmd]) do
			fmt = fmt..types.fmt[v]
		end

		return struct.pack(fmt, "ZB", self.id, self.cmd, unpack(self.args))
	end

	function msg:str()
		return "ZB id="..string.format("0x%04x", self.id)..", cmd="..string.format("0x%04x", self.cmd)
	end

	return msg
end

function message.unpack(data)
	local proto, id, cmd, offset = struct.unpack("c2I2I2", data)
	assert(proto == "ZB", "unknown protocol")

	local fmt = ""
	for k, v in ipairs(message.format[cmd]) do
		fmt = fmt..types.fmt[v]
	end

	return message.new(id, cmd, struct.unpack(fmt, data, offset))
end

return message
