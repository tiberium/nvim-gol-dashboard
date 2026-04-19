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
				line = line .. self.grid[key].char
			else
				line = line .. " "
			end
		end
		table.insert(lines, line)
	end
	return lines
end

function GOLGrid:count_live_cells()
	local count = 0

	for _ in pairs(self.grid) do
		count = count + 1
	end

	return count
end

function GOLGrid:step()
	local new_grid = {}

	for y = 1, self.y_size do
		for x = 1, self.x_size do
			local key = GOLCell.new(x, y):key()
			local live_neighbors = self:count_live_neighbors(key)

			-- cell survives
			if self.grid[key] and live_neighbors == 2 or live_neighbors == 3 then
				new_grid[key] = self.grid[key]
			end

			-- cell is born
			if not self.grid[key] and live_neighbors == 3 then
				new_grid[key] = GOLCell.new(x, y)
			end
		end
	end

	self.grid = new_grid
end

---@param key string cell key in the format "x-y"
---@return integer number of live neighbors, -1 if cell is not alive (or not part of the grid)
function GOLGrid:count_live_neighbors(key)
	local count = 0
	-- TODO Consider elements outside grid

	local x = tonumber(key:match("^(%d+)-"))
	local y = tonumber(key:match("-(%d+)$"))
	for dx = -1, 1 do
		for dy = -1, 1 do
			if not (dx == 0 and dy == 0) then
				local neighbor_key = GOLCell.new(x + dx, y + dy):key()
				if self.grid[neighbor_key] then
					count = count + 1
				end
			end
		end
	end

	return count
end

return GOLGrid
