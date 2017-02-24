local socket = require "socket"
local proto = require "network/proto"
local message = require "network/message"

local network = {}

network.port = 13337

function network.messager()
	local messager = {}

	messager.id = 0

	function messager:create(cmd)
		local msg = message.new(self.id, cmd)
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

	server.clients = {}

	function server:recv()
		local data, err_or_host, port = self.socket:receivefrom()

		if data then
			local success, msg = pcall(function() return message.unpack(data) end)
			if not success then
				print("dropping unknown message")
				return nil
			end

			if msg.cmd == proto.hello then
				self.clients[err_or_host..":"..port] = {
					host = err_or_host,
					port = port,
					x = 0,
					y = 0
				}
				self:send(self.messager:create(proto.setx), err_or_host, port)
			elseif self.clients[err_or_host..":"..port] == nil then
				print("dropping message from unknown client")
				return nil
			end
			return msg
		elseif err_or_host ~= "timeout" then
			print("socket error: "..err_or_host)
		end

		return nil
	end

	function server:send(msg, host, port)
		local success, err = self.socket:sendto(msg:pack(), host, port)
		if not success then
			print("socket error: "..err)
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

	function client:recv()
		local data, err_or_host, port = self.socket:receive()

		if data then
			return message.unpack(data)
		elseif err_or_host ~= "timeout" then
			print("socket error: "..msg_or_host)
		end

		return nil
	end

	function client:send(msg)
		local success, err = self.socket:send(msg:pack())
		if not success then
			print("socket error: "..err)
		end
		return success
	end

	return client
end

return network
