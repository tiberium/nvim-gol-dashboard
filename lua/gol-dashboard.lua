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

	self.buf_id = vim.api.nvim_get_current_buf()

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

	self:_setup_keys()

	return self
end

-- Register key listeners scoped to the dashboard buffer only.
function GOLDashboard:_setup_keys()
	local buf_id = self.buf_id

	-- Advance the GoL state on every keypress, but only while the dashboard
	-- buffer is the active buffer (fixes the previously global vim.on_key).
	self.ns_id = vim.on_key(function()
		if vim.api.nvim_get_current_buf() == buf_id then
			self:update()
		end
	end)

	-- vim.on_key fires *before* Neovim processes the key.  Replacing all
	-- buffer lines inside the callback corrupts Neovim's internal state for
	-- vertical cursor movement, so j/k stop moving the cursor even though the
	-- GoL state was already advanced.  Adding buffer-local keymaps that
	-- explicitly reposition the cursor fixes this for j and k.
	vim.keymap.set("n", "j", function()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local line_count = vim.api.nvim_buf_line_count(buf_id)
		if row < line_count then
			vim.api.nvim_win_set_cursor(0, { row + 1, col })
		end
	end, { buffer = buf_id, noremap = true, silent = true })

	vim.keymap.set("n", "k", function()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		if row > 1 then
			vim.api.nvim_win_set_cursor(0, { row - 1, col })
		end
	end, { buffer = buf_id, noremap = true, silent = true })
end

--TODO move to buffors
function GOLDashboard:update()
	self.gol_net:step()

	vim.bo[self.buf_id].modifiable = true
	vim.bo[self.buf_id].readonly = false
	vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, self.gol_net:render())
	vim.bo[self.buf_id].modifiable = false
	vim.bo[self.buf_id].readonly = true
end

return GOLDashboard
