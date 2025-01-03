local M = {
  group = vim.api.nvim_create_augroup("minesweeper", {}),
  pattern = "minesweeper",
}

---@alias MinesweeperEventKind "SHOW"|"FLAG"|"MOVE"|"QUIT"

---@class (exact) MinesweeperEvent
---@field kind MinesweeperEventKind
---@field data? any

---@class MinesweeperEventMove: MinesweeperEvent
---@field kind "MOVE"
---@field data MinesweeperMoveDir

---@class MinesweeperEventShow: MinesweeperEvent
---@field kind "SHOW"

---@class MinesweeperEventFlag: MinesweeperEvent
---@field kind "FLAG"

---@class MinesweeperEventQuit: MinesweeperEvent
---@field kind "QUIT"

---Send Event
---@param kind MinesweeperEventKind
---@param data? any
function M.send_event(kind, data)
  vim.api.nvim_exec_autocmds("User", {
    group = M.group,
    pattern = M.pattern,
    data = {
      kind = kind,
      data = data,
    },
  })
end

---@param cb fun(event: MinesweeperEvent) handler for event
function M.add_event_listener(cb)
  vim.api.nvim_create_autocmd("User", {
    group = M.group,
    pattern = M.pattern,
    callback = function(e)
      cb(e.data)
    end,
  })
end

function M.clear_event_listeners()
  vim.api.nvim_clear_autocmds({
    event = "User",
    group = M.group,
  })
end

return M
