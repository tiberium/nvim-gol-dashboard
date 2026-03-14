local M = {}

local DashboardView = require("dashboard-view")

---Function to setup the plugin
---@param opts table|nil Configuration options
function M.setup(opts)
	opts = opts or {}

	DashboardView.create_dashboard("testing")
end

return M
