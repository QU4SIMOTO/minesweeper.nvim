local new_set = MiniTest.new_set
local expect = MiniTest.expect

local child = MiniTest.new_child_neovim()

local T = new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "scripts/minimal_init.lua" })
      child.lua([[M = require("minesweeper")]])
    end,
    post_once = child.stop,
  }
})

T["toggle"] = function()
  child.cmd("Minesweeper")
  expect.reference_screenshot(child.get_screenshot())
  child.cmd("Minesweeper")
  expect.reference_screenshot(child.get_screenshot())
end

return T
