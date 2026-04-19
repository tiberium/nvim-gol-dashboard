local GOLDashboard = {}
GOLDashboard.__index = GOLDashboard

local GOLGrid = require("gol-grid")
local BufferHelpers = require("buffer-helpers")

local function normalize_header_lines(header_lines)
	if type(header_lines) == "string" then
		return { header_lines }
	end

	if type(header_lines) == "table" then
		return header_lines
	end

	return { "Game of Life" }
end

---@class GOLDashboard
function GOLDashboard.new(opts)
	local self = setmetatable({}, GOLDashboard)
	opts = opts or {}

	vim.cmd("enew")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false

	self.buf_id = vim.api.nvim_get_current_buf()
	self.step_count = 0
	self.frame_char = (opts.frame_char and tostring(opts.frame_char):sub(1, 1)) or "#"
	self.header_lines = normalize_header_lines(opts.header_lines)

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

	self:_render()

	self:_setup_keys()

	return self
end

function GOLDashboard:_render()
	local rendered_lines = self:_compose_dashboard_lines()

	BufferHelpers.with_modifiable_buffer(self.buf_id, function()
		vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, rendered_lines)
	end)
end

function GOLDashboard:_compose_dashboard_lines()
	local grid_lines = self.gol_net:render()
	local frame_width = self.gol_net.x_size + 2
	local top_bottom_border = string.rep(self.frame_char, frame_width)
	local content_lines = {}

	for _, header_line in ipairs(self.header_lines) do
		table.insert(content_lines, header_line)
	end

	table.insert(content_lines, "")
	table.insert(content_lines, top_bottom_border)

	for _, grid_line in ipairs(grid_lines) do
		table.insert(content_lines, self.frame_char .. grid_line .. self.frame_char)
	end

	table.insert(content_lines, top_bottom_border)
	table.insert(content_lines, "")

	local live_cells = self.gol_net:count_live_cells()
	table.insert(content_lines, "Live cells: " .. live_cells .. " | Step: " .. self.step_count)

	return self:_center_content(content_lines)
end

function GOLDashboard:_center_content(content_lines)
	local win_width = vim.api.nvim_win_get_width(0)
	local win_height = vim.api.nvim_win_get_height(0)
	local content_width = 0

	for _, line in ipairs(content_lines) do
		if #line > content_width then
			content_width = #line
		end
	end

	local horizontal_padding = math.max(math.floor((win_width - content_width) / 2), 0)
	local vertical_padding = math.max(math.floor((win_height - #content_lines) / 2), 0)

	local centered_lines = {}
	local left_padding = string.rep(" ", horizontal_padding)

	for _ = 1, vertical_padding do
		table.insert(centered_lines, "")
	end

	for _, line in ipairs(content_lines) do
		table.insert(centered_lines, left_padding .. line)
	end

	return centered_lines
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
	self.step_count = self.step_count + 1

	self:_render()
end

return GOLDashboard
