local M = {}

local GOLDashboard = require("gol-dashboard")

---Function to setup the plugin
---@param opts table|nil Configuration options
function M.setup(opts)
	opts = opts or {}

	local dashboard = GOLDashboard.new()

	vim.on_key(function()
		dashboard:update()
	end)
end

return M
