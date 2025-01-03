local Event = require("minesweeper.event")

local M = {}

---@param buf integer
function M.set_keymaps(buf)
  --select cell
  vim.keymap.set("n", "<CR>", function()
    Event.send_event("SHOW")
  end, { buffer = buf })
  --flag selected cell
  vim.keymap.set("n", "f", function()
    Event.send_event("FLAG")
  end, { buffer = buf })
  --quit
  vim.keymap.set("n", "q", function()
    Event.send_event("QUIT")
  end, { buffer = buf })
  --move selected left
  vim.keymap.set("n", "h", function()
    Event.send_event("MOVE", "LEFT")
  end, { buffer = buf })
  vim.keymap.set("n", "<Left>", function()
    Event.send_event("MOVE", "LEFT")
  end, { buffer = buf })
  --move selected down
  vim.keymap.set("n", "j", function()
    Event.send_event("MOVE", "DOWN")
  end, { buffer = buf })
  vim.keymap.set("n", "<Down>", function()
    Event.send_event("MOVE", "DOWN")
  end, { buffer = buf })
  --move selected up
  vim.keymap.set("n", "k", function()
    Event.send_event("MOVE", "UP")
  end, { buffer = buf })
  vim.keymap.set("n", "<Up>", function()
    Event.send_event("MOVE", "UP")
  end, { buffer = buf })
  --move selected right
  vim.keymap.set("n", "l", function()
    Event.send_event("MOVE", "RIGHT")
  end, { buffer = buf })
  vim.keymap.set("n", "<Right>", function()
    Event.send_event("MOVE", "RIGHT")
  end, { buffer = buf })
end

return M
