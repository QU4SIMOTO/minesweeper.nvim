local auto = require("minesweeper.auto")
local Game = require("minesweeper.game")
local UI = require("minesweeper.ui")

---@class Minesweeper
---@field game MinesweeperGame
---@field ui MinesweeperUI
local Minesweeper = {}
Minesweeper.__index = Minesweeper

---@return Minesweeper
function Minesweeper:new()
  local game = Game:new()
  return setmetatable({
    game = game,
    ui = UI:new({ size = game.grid.settings.size }),
  }, self)
end

---@param event MinesweeperUIEvent
function Minesweeper:handle_ui_event(event)
  if event.action == "SHOW" then
    self.game:show_cell(event.pos)
  elseif event.action == "FLAG" then
    self.game:flag_cell(event.pos)
  end
  self.ui:render(self.game:get_cells())
end

---Open the ui and setup event listener
function Minesweeper:open_ui()
  self.ui:open()
  self.ui:render(self.game:get_cells())
  vim.api.nvim_create_autocmd("User", {
    group = auto.group,
    pattern = auto.pattern,
    callback = function(e)
      self:handle_ui_event(e.data)
    end,
  })
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = self.ui.buf,
    callback = function()
      pcall(vim.api.nvim_del_autocmd, auto.group)
      self.ui:close()
    end,
  })
end

function Minesweeper:close_ui()
  self.ui:close()
end

function Minesweeper:toggle_ui()
  if self.ui:is_open() then
    self:close_ui()
  else
    self:open_ui()
  end
end

return Minesweeper
