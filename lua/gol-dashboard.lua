local GOLDashboard = {}
GOLDashboard.__index = GOLDashboard

local GOLGrid = require("gol-grid")

---@class GOLDashboard
function GOLDashboard.new()
	local self = setmetatable({}, GOLDashboard)

	vim.cmd("enew")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false

	self.gol_net = GOLGrid.new(30, 30)
	-- oscillating pattern
	self.gol_net:insert(3, 2)
	self.gol_net:insert(3, 3)
	self.gol_net:insert(3, 4)
	self.gol_net:insert(4, 3)
	self.gol_net:insert(4, 4)
	self.gol_net:insert(4, 5)

	-- const pattern
	self.gol_net:insert(10, 10)
	self.gol_net:insert(10, 11)
	self.gol_net:insert(11, 10)
	self.gol_net:insert(11, 11)

	-- TODO I want to prepare a dedicated buffer for the GOL grid. For that I want to develop a BufferRenderer
	vim.api.nvim_buf_set_lines(0, 0, -1, false, self.gol_net:render())
	vim.bo.modifiable = false
	vim.bo.readonly = true

	local first_neighbor = self.gol_net:count_live_neighbors("2-3")

	-- vim prinf first neighbor couny
	print("First neighbor count: " .. first_neighbor)

	return self
end

--TODO move to buffors
function GOLDashboard:update()
	self.gol_net:step()

	vim.bo.modifiable = true
	vim.bo.readonly = false
	vim.api.nvim_buf_set_lines(0, 0, -1, false, self.gol_net:render())
	vim.bo.modifiable = false
	vim.bo.readonly = true
end

return GOLDashboard
