---@alias MinesweeperDifficulty "EASY"|"MEDIUM"|"HARD"

---@class MinesweeperGridSettings
---@field size? integer
---@field difficulty? MinesweeperDifficulty

---@type MinesweeperGridSettings
local grid = {
  size = 10,
  difficulty = "MEDIUM",
}

---@class MinesweeperDifficultySettings
---@field mine_ratio number

local difficulty = {
  EASY = {
    mine_ratio = 0.25,
  },
  MEDIUM = {
    mine_ratio = 0.4,
  },
  HARD = {
    mine_ratio = 0.6,
  },
}

---@class MinesweeperSettings
---@field grid MinesweeperGridSettings
---@field difficulty table<MinesweeperDifficulty, MinesweeperDifficultySettings>
return {
  grid = grid,
  difficulty = difficulty,
}
