local struct = require "struct"
local socket = require "socket"
local network = {}

network.port = 13337

network.proto = {
	null    = 0,
	hello   = 1,
	goodbye = 2
}

function network.message(id, cmd)
	if not cmd then cmd = network.proto.null end

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

function network.unpackMessage(data)
	local proto, id, cmd = struct.unpack("c2I2I2", data)
	assert(proto == "ZB", "unknown protocol")
	return network.message(id, cmd)
end

function network.messager()
	local messager = {}

	messager.id = 0

	function messager:create()
		local msg = network.message(self.id)
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
			return network.unpackMessage(data)
		elseif err_or_host ~= "timeout" then
			self.print("socket error: "..err_or_host)
		end

		return nil
	end

	function server:send(message, host)
		print(self.socket)
		local success, err = self.socket:sendto(message:pack(), host, network.port)
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

	function client:send(message)
		local success, err = self.socket:send(message:pack())
		if not success then
			self.print("socket error: "..err)
		end
		return success
	end

	return client
end

return network
