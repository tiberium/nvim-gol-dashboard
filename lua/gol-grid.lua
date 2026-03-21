local GOLGrid = {}
GOLGrid.__index = GOLGrid

local GOLCell = require("gol-cell")

---@class GOLGrid
---@field x_size integer
---@field y_size integer
function GOLGrid.new(x_size, y_size)
	local self = setmetatable({}, GOLGrid)

	self.x_size = x_size
	self.y_size = y_size

	self.grid = {}

	return self
end

function GOLGrid:insert(x, y)
	-- Check y bounds
	if y < 1 or y > self.y_size then
		return false, "Y coordinate out of bounds"
	end
	-- Check x bounds
	if x < 1 or x > self.x_size then
		return false, "X coordinate out of bounds"
	end

	local cell = GOLCell.new(x, y)

	if not self.grid[cell:key()] then
		self.grid[cell:key()] = cell
		return true
	end

	return false, "Cell already exists"
end

function GOLGrid:render()
	local lines = {}
	for row = 1, self.y_size do
		local line = ""
		for col = 1, self.x_size do
			local key = GOLCell.new(col, row):key()
			if self.grid[key] then
				line = line .. self.grid[key].character
			else
				line = line .. " "
			end
		end
		table.insert(lines, line)
	end
	return lines
end

function GOLGrid:step() end

return GOLGrid
