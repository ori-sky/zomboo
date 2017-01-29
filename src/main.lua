local network = require "network"

local game = {}

function game:create()
	self.server = network.server()
	self.client = network.client()

	self.x = 0
	self.y = 0
end

function game:update(dt)
	self.server:update(dt)
	self.client:update(dt)

	self.x = self.x + 10 * dt
end

function game:draw()
	love.graphics.setColor(255, 120, 0)
	love.graphics.rectangle("fill", self.x, 0, 128, 72)
end

function love.load()
	io.stdout:setvbuf "no"
	love.window.setMode(1280, 720, {
		centered = true,
		fullscreen = false,
		love.window.setTitle("zomboo"),
		vsync = true,
		resizable = true,
		borderless = false,
		display = true,
		minwidth = 640,
		minheight = 360,
		highdpi = false
	})
	game:create()
end

function love.update(dt)
	game:update(dt)
end

function love.draw()
	game:draw()
end
