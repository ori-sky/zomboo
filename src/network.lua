local socket = require "socket"
local network = {}

network.PORT = 13337

function network.server()
	local server = {}

	server._socket = socket.udp()
	server._socket:settimeout(0)
	server._socket:setsockname("*", network.PORT)

	function server:recv()
		local data, msg_or_host, port = self._socket:receivefrom()
		if not data and msg_or_host == "timeout" then
			print("socket error:", msg_or_host)
		end
		return data
	end

	function server:update(dt)
		local data = self:recv()
		if data then print(data) end
	end

	return server
end

function network.client(host)
	if not host then host = "localhost" end

	local client = {}

	client._socket = socket.udp()
	client._socket:settimeout(0)
	client._socket:setpeername(host, network.PORT)

	function client:send(data)
		client._socket:send(data)
	end

	function client:update(dt)
		if love.math.random() < 0.1 then self:send("hello") end
	end

	return client
end

return network
