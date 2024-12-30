local Grid = require("minesweeper.grid")
local default_settings = require("minesweeper.settings")

local new_set = MiniTest.new_set
local expect = MiniTest.expect
local eq = expect.equality

---@param grid MinesweeperGrid
---@param size integer
local grid_size_eq = function(grid, size)
  eq(#grid.cells, size)
  for _, row in pairs(grid.cells) do
    eq(#row, size)
  end
end

local T = new_set()
T["new()"] = new_set()
T["generate_mines()"] = new_set()

T["new()"]["uses default settings"] = function()
  local grid = Grid:new()

  grid_size_eq(grid, default_settings.grid.size)
  eq(grid.mine_count, 40)
end

T["new()"]["uses setting"] = function()
  local size = 20
  local grid = Grid:new({ size = size })

  grid_size_eq(grid, size)
  eq(grid.mine_count, 160)
end


T["generate_mines()"]["no exlude"] = function()
  local grid = Grid:new()

  expect.no_error(function()
    grid:generate_mines()
  end)

  local mine_count = #vim.iter(grid.cells)
      :flatten()
      :filter(function(cell) return cell.is_mine end)
      :totable()

  eq(mine_count, 40)

  expect.error(function()
    grid:generate_mines()
  end)
end

T["generate_mines()"]["exclude"] = function()
  local exclude = { row = 1, col = 1 }
  local grid = Grid:new()
  local total_cells = math.pow(grid.settings.size, 2)
  grid.mine_count = total_cells - 1

  expect.no_error(function()
    grid:generate_mines(exclude)
  end)

  local iter = vim.iter(grid.cells):flatten()
  eq(iter:next().is_mine, false)
  eq(iter:all(function(cell)
    return cell.is_mine
  end), true)
end

return T
