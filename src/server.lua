local struct = require "struct"
local network = require "network"

return function()
	local server = {}
	server.TIMESTEP = 1 / 25
	server.accumulator = 0
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
		local msg = self.server:recv()
		if msg then
			self.print("recv: "..msg:str())
		end
	end

	return server
end
