local Grid = require("minesweeper.grid")

---@class MinesweeperGameSettings
---@field grid MinesweeperGridSettings

---@alias MinesweeperGameState "RUNNING"|"WON"|"LOST"

---@class MinesweeperGame
---@field grid MinesweeperGrid
---@field state MinesweeperGameState
---@field has_shown boolean Has at least one cell been shown
local MinesweeperGame = {}
MinesweeperGame.__index = MinesweeperGame

---@param settings MinesweeperGameSettings
---@return MinesweeperGame
function MinesweeperGame:new(settings)
  return setmetatable({
    grid = Grid:new(settings.grid),
    has_shown = false,
    state = "RUNNING",
  }, self)
end

---Get all the cells in the grid
---@return MinesweeperCell[][]
function MinesweeperGame:get_cells()
  return self.grid.cells
end

---Shows a cell and updates the game state
---@param pos MinesweeperGridCellPos
function MinesweeperGame:show_cell(pos)
  if self.state ~= "RUNNING" then
    return
  end

  if not self.has_shown then
    self.grid:generate_mines(pos)
    self.has_shown = true
  end

  local cell = self.grid.cells[pos.row][pos.col]

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
    self:_show_neighbours({ cell = cell, pos = pos })
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

---Toggles the cell flag
---@param pos MinesweeperGridCellPos
function MinesweeperGame:flag_cell(pos)
  if self.state == "RUNNING" then
    self.grid.cells[pos.row][pos.col]:toggle_flag()
  end
end

return MinesweeperGame
