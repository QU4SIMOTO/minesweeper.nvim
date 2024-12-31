local Cell = require("minesweeper.cell")

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local cell
local T = new_set({
  hooks = {
    pre_case = function()
      cell = Cell:new()
    end,
  }
})

T["new()"] = new_set()
T["toggle_flag()"] = new_set()

T["new()"]["state is HIDDEN"] = function ()
  eq(cell.state, "HIDDEN")
end

T["toggle_flag()"]["HIDDEN"] = function()
  cell.state = "HIDDEN"
  eq(cell:toggle_flag(), true)
  eq(cell.state, "FLAGGED")
end

T["toggle_flag()"]["FLAGGED"] = function()
  cell.state = "FLAGGED"
  eq(cell:toggle_flag(), true)
  eq(cell.state, "HIDDEN")
end

T["toggle_flag()"]["SHOWN"] = function()
  cell.state = "SHOWN"
  eq(cell:toggle_flag(), false)
  eq(cell.state, "SHOWN")
end

return T
