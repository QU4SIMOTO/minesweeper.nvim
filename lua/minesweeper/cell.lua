---@class MinesweeperCell
---@field _state "HIDDEN"|"SHOWN"|"FLAGGED"
---@field isMine boolean
local MinesweeperCell = {}
MinesweeperCell.__index = MinesweeperCell

---@return MinesweeperCell
function MinesweeperCell:new()
  return setmetatable({
    _state = "HIDDEN",
  }, self)
end

---Toggle the flag on the cell if the cell isn't shown
---@return boolean Was the cell flag actually toggled
function MinesweeperCell:toggle_flag()
  if self._state == "SHOWN" then
    return false
  end
  self._state = self._state == "HIDDEN" and "FLAGGED" or "HIDDEN"
  return true
end

---Show the cell
---@return boolean Was the cell already shown or flagged
function MinesweeperCell:show()
  if self._state ~= "HIDDEN" then
    return false
  end
  self._state = "SHOWN"
  return true
end

return MinesweeperCell
