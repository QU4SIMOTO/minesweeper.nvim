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

T["new()"]["uses default settings"] = function()
  local grid = Grid:new()

  grid_size_eq(grid, default_settings.grid.size)
  eq(grid.mine_count, 30)
end

T["new()"]["uses setting"] = function()
  local size = 20
  local grid = Grid:new({ size = size })

  grid_size_eq(grid, size)
  eq(grid.mine_count, 120)
end

T["generate_mines()"] = new_set()

T["generate_mines()"]["no exlude"] = function()
  local grid = Grid:new()

  expect.no_error(function()
    grid:generate_mines()
  end)

  local mine_count = #vim.iter(grid.cells)
      :flatten()
      :filter(function(cell) return cell.is_mine end)
      :totable()

  eq(mine_count, 30)

  expect.error(function()
    grid:generate_mines()
  end)
end

T["generate_mines()"]["exclude"] = function()
  local exclude = { row = 1, col = 1 }
  local grid = Grid:new()
  local total_cells = math.pow(grid.settings.size, 2)
  grid.mine_count = total_cells - 1

  eq(vim.iter(grid.cells):flatten():all(function(cell)
    return not cell.is_mine and cell.adj_mines == 0
  end), true)

  expect.no_error(function()
    grid:generate_mines(exclude)
  end)

  local iter = vim.iter(grid.cells):flatten()
  eq(iter:next().is_mine, false)
  eq(iter:all(function(cell)
    return cell.is_mine and cell.adj_mines > 0
  end), true)
end

T["_neighbours()"] = function()
  local size = 10
  local grid = Grid:new({ size = size })

  eq(#grid:_neighbours({ row = 1, col = 1 }), 3)
  eq(#grid:_neighbours({ row = 2, col = 1 }), 5)
  eq(#grid:_neighbours({ row = 1, col = 2 }), 5)
  eq(#grid:_neighbours({ row = 2, col = 2 }), 8)
  eq(#grid:_neighbours({ row = size, col = size }), 3)
  eq(#grid:_neighbours({ row = size - 1, col = size }), 5)
  eq(#grid:_neighbours({ row = size, col = size - 1 }), 5)

  expect.error(function() grid:_neighbours({ row = 0, col = 1 }) end)
  expect.error(function() grid:_neighbours({ row = 1, col = 0 }) end)
  expect.error(function() grid:_neighbours({ row = size + 1, col = 1 }) end)
  expect.error(function() grid:_neighbours({ row = size, col = size + 1 }) end)
end

return T
