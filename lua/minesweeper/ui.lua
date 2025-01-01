local auto = require("minesweeper.auto")

---@param cell MinesweeperCell
---@return string
local function get_cell_char(cell)
  if cell.state == "FLAGGED" then
    return "f"
  end

  if cell.state == "HIDDEN" then
    return " "
  end
  if cell.is_mine then
    return "x"
  end
  return string.format("%d", cell.adj_mines)
end

---@class MinesweeperUI
---@field grid MinesweeperGrid
---@field buf? integer
---@field win? integer
---@field config any
local MinesweeperUI = {}
MinesweeperUI.__index = MinesweeperUI

---@class MinesweeperUISettings
---@field size integer

---@param settings MinesweeperUISettings
---@return MinesweeperUI
function MinesweeperUI:new(settings)
  return setmetatable({
    buf = -1,
    win = -1,
    config = {
      win = {
        title = "Minesweeper",
        relative = "editor",
        width = settings.size,
        height = settings.size,
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
  end
  self.win = vim.api.nvim_open_win(self.buf, true, self.config.win)
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
function MinesweeperUI:render(cells)
  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })
  if not vim.api.nvim_buf_is_valid(self.buf) then
    return
  end

  local lines = {}
  for _, row in ipairs(cells) do
    local line = {}
    for _, cell in ipairs(row) do
      table.insert(line, get_cell_char(cell))
    end
    table.insert(lines, vim.iter(line):join(""))
  end
  vim.api.nvim_buf_set_lines(self.buf, 0, -1, true, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })
end

---Set the keymaps for the UI buffer
function MinesweeperUI:set_keymaps()
  vim.keymap.set("n", "<CR>", function()
    self:send_event("SHOW")
  end, { buffer = self.buf })

  vim.keymap.set("n", "f", function()
    self:send_event("FLAG")
  end, { buffer = self.buf })

  vim.keymap.set("n", "q", function()
    self:close()
  end, { buffer = self.buf })
end

---@alias MinesweeperUIEventAction "SHOW"|"FLAG"

---@class MinesweeperUIEvent
---@field action MinesweeperUIEventAction
---@field pos MinesweeperGridCellPos

---Send UI event
---@param action MinesweeperUIEventAction
function MinesweeperUI:send_event(action)
  vim.api.nvim_exec_autocmds("User", {
    group = auto.group,
    pattern = auto.pattern,
    data = { action = action, pos = self:_get_pos() },
  })
end

---Get the cell position under the cursor
---@return MinesweeperGridCellPos
function MinesweeperUI:_get_pos()
  local pos = vim.api.nvim_win_get_cursor(self.win)
  return { row = pos[1], col = pos[2] + 1 }
end

return MinesweeperUI
