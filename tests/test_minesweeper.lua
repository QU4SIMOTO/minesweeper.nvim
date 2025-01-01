local new_set = MiniTest.new_set
local expect = MiniTest.expect

local child = MiniTest.new_child_neovim()

local T = new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "scripts/minimal_init.lua" })
      child.lua([[
        M = require("minesweeper")
        M:new_game("easy", 1)
      ]])
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

T["flag"] = function()
  child.cmd("Minesweeper")
  child.type_keys("f<Cr>lflff")
  expect.reference_screenshot(child.get_screenshot())
  child.cmd("Minesweeper flag 3 3")
  expect.reference_screenshot(child.get_screenshot())
end

T["sweep"] = function()
  child.cmd("Minesweeper")
  child.type_keys("<Cr>")
  expect.reference_screenshot(child.get_screenshot())

  child.cmd("Minesweeper sweep 15 1")
  child.type_keys("<Cr>")
  expect.reference_screenshot(child.get_screenshot())
end

T["lose"] = function()
  child.cmd("Minesweeper")
  child.cmd("Minesweeper sweep 4 1")
  expect.reference_screenshot(child.get_screenshot())
end

return T
