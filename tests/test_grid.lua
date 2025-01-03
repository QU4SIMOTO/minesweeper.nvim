local Grid = require("minesweeper.grid")

local new_set = MiniTest.new_set
local expect = MiniTest.expect
local eq = expect.equality

---@type MinesweeperGridSettings
local settings = {
  width = 20,
  height = 20,
  mine_count = 5,
}

---@type MinesweeperGrid
local grid

---@param g MinesweeperGrid
---@return MinesweeperCell[]
local function get_mines(g)
  return vim.iter(g.cells)
      :flatten()
      :filter(function(cell) return cell.is_mine end)
      :totable()
end

local T = new_set({
  hooks = {
    pre_case = function()
      grid = Grid:new(settings)
    end,
  }
})

T["new()"] = function()
  eq(#get_mines(grid), 0)
  eq(
    #vim.iter(grid.cells):flatten():totable(),
    settings.width * settings.height
  )
end

T["generate_mines()"] = new_set()

T["generate_mines()"]["no exlude"] = function()
  expect.no_error(function()
    grid:generate_mines()
  end)

  eq(#get_mines(grid), settings.mine_count)

  expect.error(function()
    grid:generate_mines()
  end)
end

T["generate_mines()"]["exclude"] = function()
  local exclude = { row = 1, col = 2 }
  grid = Grid:new({
    width = settings.width,
    height = settings.height,
    mine_count = settings.width * settings.height - 1
  })

  eq(vim.iter(grid.cells):flatten():all(function(cell)
    return not cell.is_mine and cell.adj_mines == 0
  end), true)

  expect.no_error(function()
    grid:generate_mines(exclude)
  end)

  local iter = vim.iter(grid.cells):flatten()
  eq(iter:next().is_mine, true)
  eq(iter:next().is_mine, false)
  eq(iter:all(function(cell)
    return cell.is_mine and cell.adj_mines > 0
  end), true)
end

T["generate_mines()"]["seeded"] = function()
  grid = Grid:new({
    width = 10,
    height = 10,
    mine_count = 10,
    _seed = 1,
  })
  grid:generate_mines()

  eq(grid:_dbg(), {
    "2210000011",
    "xx3110001x",
    "3x3x100122",
    "11211001x1",
    "0111000111",
    "01x1000011",
    "011100001x",
    "0011100011",
    "012x100000",
    "01x2100000"
  })
end

T["neighbours()"] = function()
  grid = Grid:new(settings)
  local width = settings.width
  local height = settings.height

  eq(#grid:neighbours({ row = 1, col = 1 }), 3)
  eq(#grid:neighbours({ row = 2, col = 1 }), 5)
  eq(#grid:neighbours({ row = 1, col = 2 }), 5)
  eq(#grid:neighbours({ row = 2, col = 2 }), 8)
  eq(#grid:neighbours({ row = height, col = width }), 3)
  eq(#grid:neighbours({ row = height - 1, col = width }), 5)
  eq(#grid:neighbours({ row = height, col = width - 1 }), 5)

  expect.error(function() grid:neighbours({ row = 0, col = 1 }) end)
  expect.error(function() grid:neighbours({ row = 1, col = 0 }) end)
  expect.error(function() grid:neighbours({ row = height + 1, col = 1 }) end)
  expect.error(function() grid:neighbours({ row = height, col = width + 1 }) end)
end

T["is_complete()"] = function()
  grid = Grid:new(settings)
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
