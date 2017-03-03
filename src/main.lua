local network = require "network"
local server = require "server"
local client = require "client"

local app = {}

function app:create()
	self.server = server()
	self.server.server.packetLoss = 50
	self.client = client()
	self.client.client.packetLoss = 50
end

function app:update(dt)
	self.server:update(dt)
	self.client:update(dt)
end

function app:draw()
	self.client:draw()
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
	app:create()
end

function love.update(dt)
	app:update(dt)
end

function love.draw()
	app:draw()
end
