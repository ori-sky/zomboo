local point = require "point"

return function()
	local client = {}

	client.pos = point()

	function client.print(msg)
		print("[CLIENT] "..msg)
	end

	function client:update(dt)
		local dir = point()
		if love.keyboard.isDown("a") then dir.x = dir.x - 1 end
		if love.keyboard.isDown("d") then dir.x = dir.x + 1 end
		if love.keyboard.isDown("w") then dir.y = dir.y - 1 end
		if love.keyboard.isDown("s") then dir.y = dir.y + 1 end

		self.pos = self.pos + dir * 10
	end

	function client:draw()
		love.graphics.setColor(255, 120, 0)
		love.graphics.rectangle("fill", self.pos.x, self.pos.y, 128, 72)
	end

	return client
end
