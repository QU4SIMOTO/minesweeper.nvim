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

T["new"] = new_set()
T["new"]["works"] = function()
  expect.no_error(function()
    child.cmd("Minesweeper new")
  end)
  expect.no_error(function()
    child.cmd("Minesweeper new easy")
  end)
end
T["new"]["invalid args"] = function()
  expect.error(function()
    child.cmd("Minesweeper new easy hard")
  end)
  expect.error(function()
    child.cmd("Minesweeper new foo")
  end)
  expect.error(function()
    child.cmd("Minesweeper new foo bar")
  end)
end

T["sweep"] = new_set()
T["sweep"]["works"] = function()
  expect.no_error(function()
    child.cmd("Minesweeper sweep 1 1")
  end)
  expect.no_error(function()
    child.cmd("Minesweeper sweep 3 3")
  end)
end
T["sweep"]["invalid args"] = function()
  expect.error(function()
    child.cmd("Minesweeper sweep")
  end)
  expect.error(function()
    child.cmd("Minesweeper sweep 1")
  end)
  expect.error(function()
    child.cmd("Minesweeper sweep 1 1 3")
  end)
  expect.error(function()
    child.cmd("Minesweeper sweep 0 0")
  end)
  expect.error(function()
    child.cmd("Minesweeper sweep -1 -1")
  end)
  expect.error(function()
    child.cmd("Minesweeper sweep 100 100")
  end)
  expect.error(function()
    child.cmd("Minesweeper sweep a b")
  end)
  expect.error(function()
    child.cmd("Minesweeper sweep 1a1 1b2")
  end)
end

T["flag"] = new_set()
T["flag"]["works"] = function()
  expect.no_error(function()
    child.cmd("Minesweeper flag 1 1")
  end)
  expect.no_error(function()
    child.cmd("Minesweeper flag 3 3")
  end)
end
T["flag"]["invalid args"] = function()
  expect.error(function()
    child.cmd("Minesweeper flag")
  end)
  expect.error(function()
    child.cmd("Minesweeper flag 1")
  end)
  expect.error(function()
    child.cmd("Minesweeper flag 1 1 3")
  end)
  expect.error(function()
    child.cmd("Minesweeper flag 0 0")
  end)
  expect.error(function()
    child.cmd("Minesweeper flag -1 -1")
  end)
  expect.error(function()
    child.cmd("Minesweeper flag 100 100")
  end)
  expect.error(function()
    child.cmd("Minesweeper flag a b")
  end)
  expect.error(function()
    child.cmd("Minesweeper flag 1a1 1b2")
  end)
end

return T
