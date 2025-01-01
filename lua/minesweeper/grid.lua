local Cell = require("minesweeper.cell")

---@class MinesweeperGridCellPos
---@field row integer
---@field col integer

---@class MinesweeperGridSettings
---@field size integer Size of the grid
---@field mine_count integer Total number of mines to generate
---@field seed? integer Use fixed seed to generate mines

---@class MinesweeperGrid
---@field cells MinesweeperCell[][]
---@field settings MinesweeperGridSettings
---@field _mines_generated boolean Have the mines been generated yet
local MinesweeperGrid = {}
MinesweeperGrid.__index = MinesweeperGrid

---Instantiate the grid without the mines generated.
---This allows the mines to be generated after the user has shown at
---least one cell so that the game does not imediatly end when a cell is selected
---@param settings MinesweeperGridSettings
---@return MinesweeperGrid
function MinesweeperGrid:new(settings)
  local cells = {}
  for i = 1, settings.size do
    cells[i] = {}
    for j = 1, settings.size do
      cells[i][j] = Cell:new()
    end
  end
  return setmetatable({
    settings = settings,
    cells = cells,
  }, self)
end

---Populate the grid cells with mines
---@param exclude? MinesweeperGridCellPos exclude this cell when generating
function MinesweeperGrid:generate_mines(exclude)
  exclude = exclude or {}
  if self._mines_generated then
    error("Mines already generated")
  end
  self._mines_generated = true

  math.randomseed(self.settings.seed or os.time())

  local possible_mine_positions = {}
  for i = 1, self.settings.size do
    for j = 1, self.settings.size do
      if i ~= exclude.col or j ~= exclude.row then
        table.insert(possible_mine_positions, { col = i, row = j })
      end
    end
  end

  for _ = 1, self.settings.mine_count do
    local i = math.random(1, #possible_mine_positions)
    local pos = possible_mine_positions[i]
    local cell = self.cells[pos.row][pos.col]
    if not cell.is_mine then
      table.remove(possible_mine_positions, i)
      cell.is_mine = true
    end
  end

  for i, row in ipairs(self.cells) do
    for j, cell in ipairs(row) do
      local adj_mines = vim
        .iter(self:neighbours({ row = i, col = j }))
        :fold(0, function(acc, curr)
          if curr.cell.is_mine then
            return acc + 1
          end
          return acc
        end)
      cell.adj_mines = adj_mines
    end
  end
end

---@class MinesweeperGridNeighbour
---@field cell MinesweeperCell
---@field pos MinesweeperGridCellPos

---Get the neighbouring cells of a particular cell
---@param pos MinesweeperGridCellPos
---@return MinesweeperGridNeighbour[]
function MinesweeperGrid:neighbours(pos)
  assert(
    pos.row > 0 and pos.row <= self.settings.size,
    "Invalid row: " .. pos.row
  )
  assert(
    pos.col > 0 and pos.col <= self.settings.size,
    "Invalid col: " .. pos.col
  )
  return vim
    .iter({
      { pos.row - 1, pos.col },
      { pos.row - 1, pos.col - 1 },
      { pos.row, pos.col - 1 },
      { pos.row + 1, pos.col - 1 },
      { pos.row + 1, pos.col },
      { pos.row + 1, pos.col + 1 },
      { pos.row, pos.col + 1 },
      { pos.row - 1, pos.col + 1 },
    })
    :filter(function(p)
      return p[1] >= 1
        and p[1] <= self.settings.size
        and p[2] >= 1
        and p[2] <= self.settings.size
    end)
    :map(function(p)
      return {
        pos = { row = p[1], col = p[2] },
        cell = self.cells[p[1]][p[2]],
      }
    end)
    :totable()
end

---Have all of the empty cells been shown
---@return boolean
function MinesweeperGrid:is_complete()
  return not vim.iter(self.cells):flatten():any(function(c)
    return not c.is_mine and c.state ~= "SHOWN"
  end)
end

---For debugging and testing
---@return [string] representation of the cells
function MinesweeperGrid:_dbg()
  return vim
    .iter(self.cells)
    :map(function(row)
      return vim
        .iter(row)
        :map(function(cell)
          if cell.is_mine then
            return "x"
          else
            return string.format("%d", cell.adj_mines)
          end
        end)
        :join("")
    end)
    :totable()
end

return MinesweeperGrid
