local network = require "network"
local server

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
	server = network.server()
	client = network.client()
end

function love.update(dt)
	server:update(dt)
	client:update(dt)
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
end
