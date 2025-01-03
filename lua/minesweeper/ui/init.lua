local Hl = require("minesweeper.ui.highlights")
local Keymaps = require("minesweeper.ui.keymaps")

---@param cell MinesweeperCell Generate virtual line from cell
---@param highlights? string[]
---@return [string, string | [string]] virtual line
local function render_cell(cell, highlights)
  highlights = highlights or {}
  if cell.state == "FLAGGED" then
    return { "⚑ ", vim.list_extend({ "flag" }, highlights) }
  end
  if cell.state == "HIDDEN" then
    return { "  ", vim.list_extend({ "hidden" }, highlights) }
  end
  if cell.is_mine then
    return { "💣", vim.list_extend({ "mine" }, highlights) }
  end
  local adj = string.format("%d", cell.adj_mines)
  if adj == "0" then
    return { "𝟶 ", vim.list_extend({ adj }, highlights) }
  end
  return { adj .. " ", vim.list_extend({ adj }, highlights) }
end

---@param grid MinesweeperGrid
---@param selected MinesweeperGridCellPos
---@return [string, string | [string]][]
local function render_grid(grid, selected)
  return vim
      .iter(grid.cells)
      :enumerate()
      :map(function(i, row)
        return vim
            .iter(row)
            :enumerate()
            :map(function(j, cell)
              local is_selected = vim.deep_equal({ row = i, col = j }, selected)
              return render_cell(cell, is_selected and { "selected" } or {})
            end)
            :totable()
      end)
      :totable()
end

---@class MinesweeperUI
---@field grid MinesweeperGrid
---@field buf? integer
---@field win? integer
---@field ext_id? integer
---@field config any
local MinesweeperUI = {}
MinesweeperUI.__index = MinesweeperUI

---@class MinesweeperUISettings
---@field width integer
---@field height integer

---@param settings MinesweeperUISettings
---@return MinesweeperUI
function MinesweeperUI:new(settings)
  Hl.create_hl_groups()
  return setmetatable({
    buf = -1,
    win = -1,
    selected = { 1, 1 },
    width = settings.width,
    height = settings.height,
    ext_id = nil,
    config = {
      win = {
        title = "Minesweeper",
        title_pos = "center",
        relative = "editor",
        width = settings.width * 2,
        height = settings.height + 2,
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

  self.win = vim.api.nvim_open_win(
    self.buf,
    true,
    vim.tbl_extend("force", self.config.win, {
      row = math.floor((vim.o.lines - self.config.win.height) / 2),
      col = math.floor((vim.o.columns - self.config.win.width) / 2),
    })
  )
  vim.api.nvim_win_set_hl_ns(self.win, Hl.ns)
  Keymaps.set_keymaps(self.buf)
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
---@param game MinesweeperGame
function MinesweeperUI:render(game)
  if not vim.api.nvim_buf_is_valid(self.buf) then
    return
  end
  if self.ext_id then
    vim.api.nvim_buf_del_extmark(self.buf, Hl.ns, self.ext_id)
  end
  local grid = game.grid
  local lines = render_grid(game.grid, game.selected)
  self.ext_id = vim.api.nvim_buf_set_extmark(self.buf, Hl.ns, 0, 0, {
    virt_lines = vim.list_slice(lines, 0, grid.settings.height + 1),
    virt_lines_leftcol = true,
  })
end

return MinesweeperUI
