local Config = require("minesweeper.config")
local auto = require("minesweeper.auto")
local Game = require("minesweeper.game")
local UI = require("minesweeper.ui")

---@class MinesweeperSettings
---@field game MinesweeperGameSettings
---@field ui MinesweeperUISettings

---@param mode? MinesweeperMode
---@return MinesweeperSettings
local function get_settings(mode)
  local config = Config.get()
  mode = mode or config.default_mode
  local settings = config.modes[mode]
  if not settings then
    error("Invalid mode")
  end
  local total_cells = math.pow(settings.size, 2)

  assert(
    settings.mine_ratio > 0 and settings.mine_ratio < 1,
    "Mine ratio must be a valid ratio"
  )
  local mine_count = math.floor(total_cells * settings.mine_ratio)
  assert(mine_count < total_cells, "There must be at least one empty cell")

  return {
    game = {
      grid = {
        size = settings.size,
        mine_count = mine_count,
      },
    },
    ui = {
      size = settings.size,
    },
  }
end

---@class Minesweeper
---@field game MinesweeperGame
---@field ui MinesweeperUI
local Minesweeper = {}
Minesweeper.__index = Minesweeper

---@return Minesweeper
function Minesweeper:new()
  local settings = get_settings()
  return setmetatable({
    game = Game:new(settings.game),
    ui = UI:new(settings.ui),
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
      vim.api.nvim_clear_autocmds({
        event = "User",
        group = auto.group,
      })
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
