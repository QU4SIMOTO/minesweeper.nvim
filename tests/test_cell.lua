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
  eq(cell._state, "HIDDEN")
end

T["toggle_flag()"]["HIDDEN"] = function()
  cell._state = "HIDDEN"
  eq(cell:toggle_flag(), true)
  eq(cell._state, "FLAGGED")
end

T["toggle_flag()"]["FLAGGED"] = function()
  cell._state = "FLAGGED"
  eq(cell:toggle_flag(), true)
  eq(cell._state, "HIDDEN")
end

T["toggle_flag()"]["SHOWN"] = function()
  cell._state = "SHOWN"
  eq(cell:toggle_flag(), false)
  eq(cell._state, "SHOWN")
end

return T
