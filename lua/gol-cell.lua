local GOLCell = {}
GOLCell.__index = GOLCell

---@class GOLCell
---@field pos_x integer
---@field pos_y integer

---@return GOLCell | nil
function GOLCell.new()
	local self = setmetatable({}, GOLCell)

	self.pos_x = 0
	self.pos_y = 0

	return self
end

return GOLCell
