local Grid = require("minesweeper.grid")

---@class MinesweeperGameSettings
---@field grid MinesweeperGridSettings

---@alias MinesweeperGameState "RUNNING"|"WON"|"LOST"

---@class MinesweeperGame
---@field grid MinesweeperGrid
---@field state MinesweeperGameState
---@field selected MinesweeperGridCellPos
---@field has_shown boolean Has at least one cell been shown
local MinesweeperGame = {}
MinesweeperGame.__index = MinesweeperGame

---@param settings MinesweeperGameSettings
---@return MinesweeperGame
function MinesweeperGame:new(settings)
  return setmetatable({
    grid = Grid:new(settings.grid),
    has_shown = false,
    selected = { row = 1, col = 1 },
    state = "RUNNING",
  }, self)
end

---Get all the cells in the grid
---@return MinesweeperCell[][]
function MinesweeperGame:get_cells()
  return self.grid.cells
end

---Shows the currently selected cell
function MinesweeperGame:show_cell()
  if self.state ~= "RUNNING" then
    return
  end

  if not self.has_shown then
    self.grid:generate_mines(self.selected)
    self.has_shown = true
  end

  local cell = self.grid.cells[self.selected.row][self.selected.col]

  if not cell:show() then
    return
  end

  if cell.is_mine then
    self.state = "LOST"
    print("You lost!")
    return
  end

  if self.grid:is_complete() then
    self.state = "WON"
    print("You won!")
  end

  if cell.adj_mines == 0 then
    self:_show_neighbours({
      cell = cell,
      pos = self.selected,
    })
  end
end

---Recursively show all neighbouring cells that
---are not adjacent to a mine
---@param neighbour MinesweeperGridNeighbour
function MinesweeperGame:_show_neighbours(neighbour)
  for n in
    vim.iter(self.grid:neighbours(neighbour.pos)):filter(function(n)
      return n.cell.state == "HIDDEN"
    end)
  do
    n.cell:show()
    if n.cell.adj_mines == 0 then
      self:_show_neighbours(n)
    end
  end
end

---Toggles the flag on the currently selected cell
function MinesweeperGame:flag_cell()
  if self.state == "RUNNING" then
    self.grid.cells[self.selected.row][self.selected.col]:toggle_flag()
  end
end

---@alias MinesweeperMoveDir "LEFT"|"RIGHT"|"UP"|"DOWN"

---Move the selected cell in a particular direction
---@param dir MinesweeperMoveDir
function MinesweeperGame:move(dir)
  local size = self.grid.settings.size
  if dir == "LEFT" then
    self.selected.col = math.max(self.selected.col - 1, 1)
  elseif dir == "RIGHT" then
    self.selected.col = math.min(self.selected.col + 1, size)
  elseif dir == "UP" then
    self.selected.row = math.max(self.selected.row - 1, 1)
  elseif dir == "DOWN" then
    self.selected.row = math.min(self.selected.row + 1, size)
  end
end

return MinesweeperGame
