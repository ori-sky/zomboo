local socket = require "socket"
local message = require "network/message"

local network = {}

network.port = 13337

function network.messager()
	local messager = {}

	messager.id = 0

	function messager:create()
		local msg = message.new(self.id)
		self.id = self.id + 1
		if self.id > 65535 then self.id = 0 end
		return msg
	end

	return messager
end

function network.server()
	local server = {}

	server.messager = network.messager()

	server.socket = socket.udp()
	server.socket:settimeout(0)
	server.socket:setsockname("*", network.port)

	function server:recv()
		local data, err_or_host, port = self.socket:receivefrom()

		if data then
			return message.unpack(data)
		elseif err_or_host ~= "timeout" then
			self.print("socket error: "..err_or_host)
		end

		return nil
	end

	function server:send(msg, host)
		print(self.socket)
		local success, err = self.socket:sendto(msg:pack(), host, network.port)
		if not success then
			self.print("socket error: "..err)
		end
		return success
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

	function client.print(msg)
		print("[CLIENT] "..msg)
	end

	function client:recv()
		local data, err_or_host, port = self.socket:receive()

		if data then
			return network.unpackMessage(data)
		elseif err_or_host ~= "timeout" then
			self.print("socket error: "..msg_or_host)
		end

		return nil
	end

	function client:send(msg)
		local success, err = self.socket:send(msg:pack())
		if not success then
			self.print("socket error: "..err)
		end
		return success
	end

	return client
end

return network
