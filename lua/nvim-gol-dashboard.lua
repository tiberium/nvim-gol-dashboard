local M = {}

local GOLDashboard = require("gol-dashboard")

---Function to setup the plugin
---@param opts table|nil Configuration options
function M.setup(opts)
	opts = opts or {}

	GOLDashboard.new(opts)
end

return M
