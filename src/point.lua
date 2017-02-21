function point(x, y)
	if not x then x = 0 end
	if not y then y = x end

	local p = {}

	p.x = x
	p.y = y

	local mt = {}

	function mt.__add(a, b)
		if type(a) == "number" then a = point(a, a) end
		if type(b) == "number" then b = point(b, b) end
		return point(a.x + b.x, a.y + b.y)
	end

	function mt.__mul(a, b)
		if type(a) == "number" then a = point(a, a) end
		if type(b) == "number" then b = point(b, b) end
		return point(a.x * b.x, a.y * b.y)
	end

	setmetatable(p, mt)

	return p
end

return point
