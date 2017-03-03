local socket = require "socket"
local proto = require "network/proto"
local message = require "network/message"

local network = {}

network.port = 13337

function network.messager()
	local messager = {}

	messager.id = 0

	function messager:create(cmd, ...)
		local msg = message.new(self.id, cmd, ...)
		self.id = self.id + 1
		if self.id > 65535 then self.id = 0 end
		return msg
	end

	return messager
end

network.err = {
	none    = 0,
	socket  = 1,
	nodata  = 2,
	invalid = 3,
	noauth  = 4
}

function network.server()
	local server = {}

	server.messager = network.messager()

	server.socket = socket.udp()
	server.socket:settimeout(0)
	server.socket:setsockname("*", network.port)

	server.clients = {}

	-- packet loss simulation percentage
	server.packetLoss = 0

	function server:recv()
		local data, err_or_host, port = self.socket:receivefrom()
		if not data then
			if err_or_host ~= "timeout" then
				return network.err.socket
			else
				return network.err.nodata
			end
		end

		if math.random(0, 100) < self.packetLoss then
			return network.err.nodata
		end

		local success, msg_or_err = pcall(function() return message.unpack(data) end)
		if not success then
			return network.err.invalid
		end

		if msg_or_err.cmd == proto.hello then
			self.clients[err_or_host..":"..port] = {
				host = err_or_host,
				port = port,
				x = 0,
				y = 0
			}
		elseif self.clients[err_or_host..":"..port] == nil then
			return network.err.noauth, msg_or_err
		end

		return network.err.none, msg_or_err
	end

	function server:send(msg, host, port)
		local success, err = self.socket:sendto(msg:pack(), host, port)
		if not success then
			return network.err.socket
		end

		return network.err.none
	end

	return server
end

function network.client(host)
	if not host then host = "localhost" end

	local client = {}

	client.messager = network.messager()

	client.socket = socket.udp()
	client.socket:settimeout(0)
	client.socket:setpeername(host, network.port)

	-- packet loss simulation percentage
	client.packetLoss = 0

	function client:recv()
		local data, err_or_host, port = self.socket:receive()

		if not data then
			if err_or_host ~= "timeout" then
				return network.err.socket
			else
				return network.err.nodata
			end
		end

		if math.random(0, 100) < self.packetLoss then
			return network.err.nodata
		end

		local success, msg_or_err = pcall(function() return message.unpack(data) end)
		if not success then
			return network.err.invalid
		end

		return network.err.none, msg_or_err
	end

	function client:send(msg)
		local success, err = self.socket:send(msg:pack())
		if not success then
			return network.err.socket
		end

		return network.err.none
	end

	return client
end

return network
