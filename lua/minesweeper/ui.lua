local auto = require("minesweeper.auto")

---Send UI event
---@param action MinesweeperUIEventAction
local function send_event(action)
  vim.api.nvim_exec_autocmds("User", {
    group = auto.group,
    pattern = auto.pattern,
    data = action,
  })
end

---@param cell MinesweeperCell
---@param is_selected boolean
---@return [string, string | [string]]
local function render_cell(cell, is_selected)
  local temp = is_selected and { "selected" } or {}
  if cell.state == "FLAGGED" then
    return { "⚑ ", vim.list_extend({ "flag" }, temp) }
  end
  if cell.state == "HIDDEN" then
    return { "  ", vim.list_extend({ "hidden" }, temp) }
  end
  if cell.is_mine then
    return { "💣", temp }
  end
  local adj = string.format("%d", cell.adj_mines)
  return { adj .. " ", vim.list_extend({ adj }, temp) }
end

---@param ns integer
local function create_hl_groups(ns)
  local hidden_bg = "#555555"
  local show_bg = "#888888"
  local selected_bg = "#BBBBBB"
  vim.api.nvim_set_hl(ns, "1", {
    fg = "blue",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(ns, "2", {
    fg = "green",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(ns, "3", {
    fg = "red",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(ns, "4", {
    fg = "red",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(ns, "flag", {
    bg = show_bg,
  })
  vim.api.nvim_set_hl(ns, "bomb", {
    fg = "black",
    bg = "red",
  })
  vim.api.nvim_set_hl(ns, "selected", {
    bg = selected_bg,
    fg = "#222222",
  })
  vim.api.nvim_set_hl(ns, "hidden", {
    bg = hidden_bg,
  })
end

---@class MinesweeperUI
---@field grid MinesweeperGrid
---@field buf? integer
---@field win? integer
---@field ns integer
---@field ext_id? integer
---@field config any
local MinesweeperUI = {}
MinesweeperUI.__index = MinesweeperUI

---@class MinesweeperUISettings
---@field size integer

---@param settings MinesweeperUISettings
---@return MinesweeperUI
function MinesweeperUI:new(settings)
  local ns = vim.api.nvim_create_namespace("minesweeper")
  create_hl_groups(ns)
  return setmetatable({
    buf = -1,
    win = -1,
    ns = ns,
    selected = { 1, 1 },
    size = settings.size,
    ext_id = nil,
    config = {
      size = settings.size,
      win = {
        title = "Minesweeper",
        relative = "editor",
        width = settings.size * 2,
        height = settings.size + 2,
        row = 0,
        col = 0,
        style = "minimal",
        border = "rounded",
        zindex = 1,
      },
    },
  }, self)
end

---Open the UI
function MinesweeperUI:open()
  if not vim.api.nvim_buf_is_valid(self.buf) then
    self.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })
  end
  self.win = vim.api.nvim_open_win(self.buf, true, self.config.win)
  vim.api.nvim_win_set_hl_ns(self.win, self.ns)
  self:set_keymaps()
end

---Close the UI
function MinesweeperUI:close()
  if not vim.api.nvim_win_is_valid(self.win) then
    return
  end
  vim.api.nvim_win_close(self.win, true)
  self.win = -1
end

---@return boolean
function MinesweeperUI:is_open()
  return vim.api.nvim_win_is_valid(self.win)
end

---Render the UI
---@param cells MinesweeperCell[][]
---@param selected MinesweeperGridCellPos
function MinesweeperUI:render(cells, selected)
  if not vim.api.nvim_buf_is_valid(self.buf) then
    return
  end
  if self.ext_id then
    vim.api.nvim_buf_del_extmark(self.buf, self.ns, self.ext_id)
  end

  local lines = vim.list_extend(
    {},
    vim
      .iter(cells)
      :enumerate()
      :map(function(i, row)
        return vim
          .iter(row)
          :enumerate()
          :map(function(j, cell)
            return render_cell(cell, i == selected.row and j == selected.col)
          end)
          :totable()
      end)
      :totable()
  )

  self.ext_id = vim.api.nvim_buf_set_extmark(self.buf, self.ns, 0, 0, {
    virt_lines = vim.list_slice(lines, 0, #cells + 1),
    virt_lines_leftcol = true,
  })
end

---Set the keymaps for the UI buffer
function MinesweeperUI:set_keymaps()
  vim.keymap.set("n", "<CR>", function()
    send_event("SHOW")
  end, { buffer = self.buf })
  vim.keymap.set("n", "h", function()
    send_event("LEFT")
  end, { buffer = self.buf })
  vim.keymap.set("n", "j", function()
    send_event("DOWN")
  end, { buffer = self.buf })
  vim.keymap.set("n", "k", function()
    send_event("UP")
  end, { buffer = self.buf })
  vim.keymap.set("n", "l", function()
    send_event("RIGHT")
  end, { buffer = self.buf })

  vim.keymap.set("n", "f", function()
    send_event("FLAG")
  end, { buffer = self.buf })
  vim.keymap.set("n", "q", function()
    self:close()
  end, { buffer = self.buf })
end

---@alias MinesweeperUIEventAction "SHOW"|"FLAG"|MinesweeperMoveDir

---@class MinesweeperUIEvent
---@field action MinesweeperUIEventAction
---@field pos MinesweeperGridCellPos

return MinesweeperUI
