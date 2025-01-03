local M = {
  ns = vim.api.nvim_create_namespace("minesweeper"),
}

---Create highlight groups
function M.create_hl_groups()
  local hidden_bg = "#555555"
  local show_bg = "#888888"
  local selected_bg = "#BBBBBB"
  vim.api.nvim_set_hl(M.ns, "0", {
    fg = "#777777",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(M.ns, "1", {
    fg = "blue",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(M.ns, "2", {
    fg = "green",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(M.ns, "3", {
    fg = "red",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(M.ns, "4", {
    fg = "red",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(M.ns, "5", {
    fg = "red",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(M.ns, "6", {
    fg = "red",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(M.ns, "7", {
    fg = "red",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(M.ns, "8", {
    fg = "red",
    bg = show_bg,
  })
  vim.api.nvim_set_hl(M.ns, "flag", {
    bg = show_bg,
  })
  vim.api.nvim_set_hl(M.ns, "bomb", {
    fg = "black",
    bg = "red",
  })
  vim.api.nvim_set_hl(M.ns, "selected", {
    bg = selected_bg,
    fg = "#222222",
  })
  vim.api.nvim_set_hl(M.ns, "hidden", {
    bg = hidden_bg,
  })
end

return M
