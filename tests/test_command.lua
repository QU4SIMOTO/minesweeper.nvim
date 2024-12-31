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

T["default"] = new_set()
T["default"]["works"] = function()
  expect.no_error(function()
    child.cmd("Minesweeper")
  end)
end

T["toggle"] = new_set()
T["toggle"]["works"] = function()
  expect.no_error(function()
    child.cmd("Minesweeper toggle")
  end)
end

T["toggle"]["args"] = function()
  expect.error(function()
    child.cmd("Minesweeper toggle foo")
  end)
  expect.error(function()
    child.cmd("Minesweeper toggle foo bar")
  end)
end

return T
