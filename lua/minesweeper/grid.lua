local Cell = require("minesweeper.cell")
local default_settings = require("minesweeper.settings")

---@class MinesweeperGridCellIndex
---@field row integer
---@field col integer

---@class MinesweeperGrid
---@field cells MinesweeperCell[][]
---@field settings MinesweeperGridSettings
---@field mine_count integer
---@field _mines_generated boolean
local MinesweeperGrid = {}
MinesweeperGrid.__index = MinesweeperGrid

---Instantiate the grid without the mines generated.
---This allows the mines to be generated after the user has shown at
---least one cell so that the game does not imediatly end when a cell is selected
---@param settings? MinesweeperGridSettings
---@return MinesweeperGrid
function MinesweeperGrid:new(settings)
  settings = settings or {}
  settings.size = settings.size or default_settings.grid.size
  settings.difficulty = settings.difficulty or default_settings.grid.difficulty

  local cells = {}
  for i = 1, settings.size do
    cells[i] = {}

    for j = 1, settings.size do
      cells[i][j] = Cell:new()
    end
  end

  local total_cells = math.pow(settings.size, 2)
  local mine_ratio = default_settings.difficulty[settings.difficulty].mine_ratio
  assert(mine_ratio < 1, "Mine ratio must be a valid ratio")

  local mine_count = math.floor(total_cells * mine_ratio)

  --- Must have at least one empty cell
  assert(mine_count < total_cells)

  return setmetatable({
    settings = settings,
    cells = cells,
    mine_count = mine_count,
  }, self)
end

---Populate the grid cells with mines
---@param exclude? MinesweeperGridCellIndex exclude this cell when generating
function MinesweeperGrid:generate_mines(exclude)
  exclude = exclude or {}
  if self._mines_generated then
    error("Mines already generated")
  end
  self._mines_generated = true

  math.randomseed(os.time())

  local possible_mine_positions = {}
  for i = 1, self.settings.size do
    for j = 1, self.settings.size do
      if i ~= exclude.row or j ~= exclude.col then
        table.insert(possible_mine_positions, { col = i, row = j })
      end
    end
  end

  for _ = 1, self.mine_count  do
    local i = math.random(1, #possible_mine_positions)
    local pos = possible_mine_positions[i]
    local cell = self.cells[pos.row][pos.col]
    if not cell.is_mine then
      table.remove(possible_mine_positions, i)
      cell.is_mine = true
    end
  end
end

return MinesweeperGrid
