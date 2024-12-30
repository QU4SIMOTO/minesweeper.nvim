local Grid = require("minesweeper.grid")
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set()

T["new()"] = new_set()

T["new()"]["defaults to grid size 10"] = function()
  local grid = Grid:new()

  eq(#grid.cells, 10)

  for _, row in pairs(grid.cells) do
    eq(#row, 10)
  end
end

T["new()"]["uses size setting"] = function()
  local size = 20
  local grid = Grid:new({ size = size })

  eq(#grid.cells, size)

  for _, row in pairs(grid.cells) do
    eq(#row, size)
  end
end

return T
