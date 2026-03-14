local M = {}

local GOLNet = require("gol-net")

---Creates the dashboard buffer and fills it with data
---@param username string
function M.create_dashboard(username)
	vim.cmd("enew")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false

	local gol_net = GOLNet.new(30, 7)
	gol_net:insert(1, 1, "A")
	gol_net:insert(29, 5, "B")

	vim.api.nvim_buf_set_lines(0, 0, -1, false, gol_net:as_lines())
	vim.bo.modifiable = false
	vim.bo.readonly = true
end

return M
