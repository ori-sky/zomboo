local struct = require "struct"
local network = require "network"

return function()
	local server = {}
	server.TIMESTEP = 1 / 25
	server.accumulator = 0
	server.m = network.messager()
	server.server = network.server()

	function server.print(msg)
		print("[SERVER] "..msg)
	end

	function server:update(dt)
		self.accumulator = self.accumulator + dt
		if self.accumulator >= self.TIMESTEP then
			self:tick(self.TIMESTEP)
			self.accumulator = self.accumulator - self.TIMESTEP
		end
	end

	function server:tick(dt)
		local msg = self.m:new()
		local status, err = pcall(function() self.server:unpack(msg:pack()) end)
		if not status then self.print(err) end
	end

	return server
end
