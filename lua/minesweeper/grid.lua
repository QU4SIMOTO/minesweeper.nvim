local Cell = require("minesweeper.cell")

---@class MinesweeperGridSettings
---@field size? integer
---@field difficulty? "EASY"|"MEDIUM"|"HARD"
---
---@type MinesweeperGridSettings
local default_config = {
  size = 10,
  difficulty = "MEDIUM",
}

---@class MinesweeperGrid
---@field cells MinesweeperCell[][]
---@field settings MinesweeperGridSettings
local MinesweeperGrid = {}
MinesweeperGrid.__index = MinesweeperGrid

---@param settings? MinesweeperGridSettings
---@return MinesweeperGrid
function MinesweeperGrid:new(settings)
  local _settings = settings or {}
  _settings.size = _settings.size or default_config.size
  _settings.difficulty = _settings.difficulty or default_config.difficulty

  local cells = {}
  for i = 1, _settings.size do
    cells[i] = {}

    for j = 1, _settings.size do
      cells[i][j] = Cell:new()
    end
  end

  return setmetatable({
    settings = _settings,
    cells = cells,
  }, self)
end

return MinesweeperGrid
