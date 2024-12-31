---@class MinesweeperCell
---@field state "HIDDEN"|"SHOWN"|"FLAGGED"
---@field is_mine boolean
---@field adj_mines integer
local MinesweeperCell = {}
MinesweeperCell.__index = MinesweeperCell

---@return MinesweeperCell
function MinesweeperCell:new()
  return setmetatable({
    state = "HIDDEN",
    is_mine = false,
    adj_mines = 0,
  }, self)
end

---Toggle the flag on the cell if the cell isn't shown
---@return boolean Was the cell flag actually toggled
function MinesweeperCell:toggle_flag()
  if self.state == "SHOWN" then
    return false
  end
  self.state = self.state == "HIDDEN" and "FLAGGED" or "HIDDEN"
  return true
end

---Show the cell
---@return boolean Was the cell already shown or flagged
function MinesweeperCell:show()
  if self.state ~= "HIDDEN" then
    return false
  end
  self.state = "SHOWN"
  return true
end

return MinesweeperCell
