local GOLNet = {}
GOLNet.__index = GOLNet

---@class GOLNet
---@field x_size integer
---@field y_size integer
function GOLNet.new(x_size, y_size)
	local self = setmetatable({}, GOLNet)

	self.x_size = x_size
	self.y_size = y_size
	self.grid = {}
	for col = 1, self.x_size do
		self.grid[col] = {}
		for row = 1, self.y_size do
			self.grid[col][row] = " "
		end
	end

	return self
end

function GOLNet:insert(x, y, character)
	-- Check y bounds
	if y < 1 or y > self.y_size then
		return false, "Y coordinate out of bounds"
	end
	-- Check x bounds
	if x < 1 or x > self.x_size then
		return false, "X coordinate out of bounds"
	end
	-- Insert character
	self.grid[x][y] = character

	return true
end

function GOLNet:as_lines()
	local lines = {}
	for row = 1, self.y_size do
		local line = ""
		for col = 1, self.x_size do
			line = line .. self.grid[col][row]
		end
		table.insert(lines, line)
	end
	return lines
end

return GOLNet
