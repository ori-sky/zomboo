local struct = require "struct"
local network = require "network"
local proto = require "network/proto"

return function()
	local server = {}
	server.timestep = 1 / 25
	server.accumulator = 0
	server.server = network.server()

	function server.print(msg)
		print("[SERVER] "..msg)
	end

	function server:debug(msg)
		self.print("[DEBUG] "..msg)
	end

	function server:update(dt)
		self.accumulator = self.accumulator + dt
		if self.accumulator >= self.timestep then
			self:tick(self.timestep)
			self.accumulator = self.accumulator - self.timestep
		end
	end

	function server:tick(dt)
		local err, msg = self.server:recv()
		if err == network.err.none then
			self:debug("recv: "..msg:str())
		elseif err ~= network.err.nodata then
			self:debug("err: "..err)
		end
		for k, v in pairs(self.server.clients) do
			local msg = self.server.messager:create(proto.setx, math.random(0, 128))
			self.server:send(msg, v.host, v.port)
			local msg = self.server.messager:create(proto.sety, math.random(0, 72))
			self.server:send(msg, v.host, v.port)
		end
	end

	return server
end
