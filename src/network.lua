local socket = require "socket"
local network = {}

network.PORT = 13337

function network.server()
	local server = {}

	server._socket = socket.udp()
	server._socket:settimeout(0)
	server._socket:setsockname("*", network.PORT)

	server.clients = {}

	function server.print(msg)
		print("[SERVER] "..msg)
	end

	function server:newClient(host, port)
		local client = {}

		client.server = self
		client.host = host
		client.port = port

		function client:send(data)
			self.server:sendto(data, self.host, self.port)
		end

		return client
	end

	function server:accept(host, port)
		table.insert(self.clients, self:newClient(host, port))
		self.print("accept from "..host..":"..port)
	end

	function server:recv()
		local data, msg_or_host, port = self._socket:receivefrom()

		if data then
			self.print("recvfrom "..msg_or_host..":"..port.." "..data)
			if data == "hello" then
				self:accept(msg_or_host, port)
			end
		elseif msg_or_host ~= "timeout" then
			self.print("socket error: "..msg_or_host)
		end

		return data, msg_or_host, port
	end

	function server:sendto(data, host, port)
		local success, msg = self._socket:sendto(data, host, port)
		if success then
			self.print("sendto "..host..":"..port.." "..data)
		else
			self.print("socket error: "..msg)
		end
	end

	function server:update(dt)
		local data, host, port = self:recv()
		for i, client in ipairs(self.clients) do
			client:send("tick")
		end
	end

	return server
end

function network.client(host)
	if not host then host = "localhost" end

	local client = {}

	client._socket = socket.udp()
	client._socket:settimeout(0)
	client._socket:setpeername(host, network.PORT)

	function client.print(msg)
		print("[CLIENT] "..msg)
	end

	function client:recv()
		local data, msg = self._socket:receive()

		if data then
			self.print("recv "..data)
		elseif msg ~= "timeout" then
			self.print("socket error: "..msg)
		end

		return data
	end

	function client:send(data)
		local success, msg = self._socket:send(data)
		if success then
			self.print("send "..data)
		else
			self.print("socket error: "..msg)
		end
	end

	function client:update(dt)
		local data = self:recv()
		if love.math.random() < 0.01 then self:send("hello") end
	end

	return client
end

return network
