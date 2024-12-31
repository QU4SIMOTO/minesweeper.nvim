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
    mine_ratio = 0.1,
  },
  MEDIUM = {
    mine_ratio = 0.3,
  },
  HARD = {
    mine_ratio = 0.5,
  },
}

---@class MinesweeperSettings
---@field grid MinesweeperGridSettings
---@field difficulty table<MinesweeperDifficulty, MinesweeperDifficultySettings>
return {
  grid = grid,
  difficulty = difficulty,
}
