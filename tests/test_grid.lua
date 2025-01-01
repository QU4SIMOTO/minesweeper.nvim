local Grid = require("minesweeper.grid")
local default_config = require("minesweeper.config")

local new_set = MiniTest.new_set
local expect = MiniTest.expect
local eq = expect.equality

---@type MinesweeperGridSettings
local settings = {
  size = 20,
  mine_count = 5,
}

local T = new_set()

T["new()"] = function()
  local grid = Grid:new(settings)
  eq(
    #vim.iter(grid.cells):flatten():totable(),
    math.pow(settings.size, 2)
  )
end

T["generate_mines()"] = new_set()

T["generate_mines()"]["no exlude"] = function()
  local grid = Grid:new(settings)

  expect.no_error(function()
    grid:generate_mines()
  end)

  local mine_count = #vim.iter(grid.cells)
      :flatten()
      :filter(function(cell) return cell.is_mine end)
      :totable()

  eq(mine_count, settings.mine_count)

  expect.error(function()
    grid:generate_mines()
  end)
end

T["generate_mines()"]["exclude"] = function()
  local exclude = { row = 1, col = 1 }
  local grid = Grid:new({
    size = settings.size,
    mine_count = math.pow(settings.size, 2) - 1
  })
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

T["neighbours()"] = function()
  local grid = Grid:new(settings)
  local size = settings.size

  eq(#grid:neighbours({ row = 1, col = 1 }), 3)
  eq(#grid:neighbours({ row = 2, col = 1 }), 5)
  eq(#grid:neighbours({ row = 1, col = 2 }), 5)
  eq(#grid:neighbours({ row = 2, col = 2 }), 8)
  eq(#grid:neighbours({ row = size, col = size }), 3)
  eq(#grid:neighbours({ row = size - 1, col = size }), 5)
  eq(#grid:neighbours({ row = size, col = size - 1 }), 5)

  expect.error(function() grid:neighbours({ row = 0, col = 1 }) end)
  expect.error(function() grid:neighbours({ row = 1, col = 0 }) end)
  expect.error(function() grid:neighbours({ row = size + 1, col = 1 }) end)
  expect.error(function() grid:neighbours({ row = size, col = size + 1 }) end)
end

T["is_complete()"] = function()
  local grid = Grid:new(settings)
  grid:generate_mines()

  eq(grid:is_complete(), false)

  local iter = vim.iter(grid.cells):flatten():filter(function(cell)
    return not cell.is_mine
  end)

  local final_cell = iter:next()

  for cell in iter do
    cell:show()
    eq(grid:is_complete(), false)
  end

  final_cell:show()
  eq(grid:is_complete(), true)
end

return T
