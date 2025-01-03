local M = {}

---@alias MinesweeperMode string

---@class MinesweeperModeConfig
---@field width integer
---@field height integer
---@field mine_ratio number

---@alias MinesweeperModesConfig table<MinesweeperMode, MinesweeperModeConfig>

---@class MinesweeperConfig
---@field modes? MinesweeperModesConfig
---@field default_mode? MinesweeperMode

---@type MinesweeperConfig | fun(): MinesweeperConfig | nil
vim.g.minesweeper = vim.g.minesweeper

---@class MinesweeperInternalConfig
M.default_config = {
  ---@type MinesweeperModesConfig
  modes = {
    easy = {
      width = 15,
      height = 15,
      mine_ratio = 0.1,
    },
    medium = {
      width = 20,
      height = 20,
      mine_ratio = 0.2,
    },
    hard = {
      width = 50,
      height = 30,
      mine_ratio = 0.3,
    },
  },
  ---@type MinesweeperMode
  default_mode = "easy",
}

---@return MinesweeperInternalConfig
function M.get()
  local user_config = type(vim.g.my_plugin) == "function" and vim.g.my_plugin()
    or vim.g.my_plugin
    or {}

  --todo add validation
  return vim.tbl_deep_extend("force", M.default_config, user_config or {})
end

return M
