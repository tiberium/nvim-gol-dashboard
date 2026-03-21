local M = {}

local GOLGrid = require("gol-grid")

---Creates the dashboard buffer and fills it with data
---@param username string
function M.create_dashboard(username)
	vim.cmd("enew")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false

	local gol_net = GOLGrid.new(30, 7)
	gol_net:insert(1, 1)
	gol_net:insert(3, 3)
	gol_net:insert(29, 5)

	-- TODO I want to prepare a dedicated buffer for the GOL grid. For that I want to develop a BufferRenderer
	vim.api.nvim_buf_set_lines(0, 0, -1, false, gol_net:render())
	vim.bo.modifiable = false
	vim.bo.readonly = true
end

return M
