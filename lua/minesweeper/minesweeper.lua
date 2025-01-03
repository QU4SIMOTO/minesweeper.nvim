local Config = require("minesweeper.config")
local Game = require("minesweeper.game")
local UI = require("minesweeper.ui")
local Event = require("minesweeper.event")

---@class MinesweeperSettings
---@field game MinesweeperGameSettings
---@field ui MinesweeperUISettings

---@param mode? MinesweeperMode
---@param seed? integer
---@return MinesweeperSettings
local function get_settings(mode, seed)
  local config = Config.get()
  mode = mode or config.default_mode
  local settings = config.modes[mode]
  if not settings then
    error("Invalid mode")
  end
  local total_cells = settings.width * settings.height

  assert(
    settings.mine_ratio > 0 and settings.mine_ratio < 1,
    "Mine ratio must be a valid ratio"
  )
  local mine_count = math.floor(total_cells * settings.mine_ratio)
  assert(mine_count < total_cells, "There must be at least one empty cell")

  return {
    game = {
      grid = {
        width = settings.width,
        height = settings.height,
        mine_count = mine_count,
        _seed = seed,
      },
    },
    ui = {
      width = settings.width,
      height = settings.height,
    },
  }
end

---@class Minesweeper
---@field game MinesweeperGame
---@field ui MinesweeperUI
local Minesweeper = {}
Minesweeper.__index = Minesweeper

---@param mode? MinesweeperMode
---@param seed? integer for testing
---@return Minesweeper
function Minesweeper:new(mode, seed)
  local settings = get_settings(mode, seed)
  return setmetatable({
    game = Game:new(settings.game),
    ui = UI:new(settings.ui),
  }, self)
end

---Open the ui and setup event listener
function Minesweeper:open_ui()
  self.ui:open()
  self:_update_ui()
  Event.add_event_listener(function(event)
    self:_handle_event(event)
  end)
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = self.ui.buf,
    callback = function()
      Event.clear_event_listeners()
      self.ui:close()
    end,
  })
end

---Close the ui
function Minesweeper:close_ui()
  self.ui:close()
end

---Toggle the ui
function Minesweeper:toggle_ui()
  if self.ui:is_open() then
    self:close_ui()
  else
    self:open_ui()
  end
end

---Move the cursor
---@param dir MinesweeperMoveDir
function Minesweeper:move(dir)
  self.game:move(dir)
  self:_update_ui()
end

---Move the cursor to a particular cell
---@param pos MinesweeperGridCellPos
function Minesweeper:select(pos)
  self.game:select(pos)
  self:_update_ui()
end

---Show the cell under the cursor
function Minesweeper:show()
  self.game:show_cell()
  self:_update_ui()
end

---Flag the cell under the cursor
function Minesweeper:flag()
  self.game:flag_cell()
  self:_update_ui()
end

---Start a new game
---@param mode? MinesweeperMode
---@param seed? integer used for testing
function Minesweeper:new_game(mode, seed)
  local settings = get_settings(mode, seed)
  local was_open = self.ui:is_open()
  self:close_ui()
  self.game = Game:new(settings.game)
  self.ui = UI:new(settings.ui)
  if was_open then
    self:open_ui()
  end
end

function Minesweeper:_update_ui()
  if self.ui:is_open() then
    self.ui:render(self.game:get_cells(), self.game.selected)
  end
end

---@param event MinesweeperEvent
function Minesweeper:_handle_event(event)
  if event.kind == "SHOW" then
    self:show()
  elseif event.kind == "FLAG" then
    self:flag()
  elseif event.kind == "QUIT" then
    self:close_ui()
  elseif event.kind == "MOVE" then
    self:move(event.data)
  end
end

return Minesweeper
