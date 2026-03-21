local GOLCell = {}
GOLCell.__index = GOLCell

---@class GOLCell
---@field x integer
---@field y integer
function GOLCell.new(x, y)
	local self = setmetatable({}, GOLCell)

	self.x = x
	self.y = y

	self.character = "X"

	return self
end

function GOLCell:key()
	return tostring(self.x) .. "-" .. tostring(self.y)
end

return GOLCell
