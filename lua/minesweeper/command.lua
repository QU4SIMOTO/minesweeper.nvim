local M = {}
local default_key = "toggle"

---@class MinesweeperSubcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback

---@type table<string, MinesweeperSubcommand>
M.subcommand_tbl = {
  toggle = {
    impl = function(args)
      if #args > 0 then
        vim.notify(
          "Minesweeper toggle: command does not accept arguments",
          vim.log.levels.ERROR
        )
        return
      end
      require("minesweeper"):toggle_ui()
    end,
  },
}

---@param opts table :h lua-guide-commands-create
M.cmd = function(opts)
  local fargs = opts.fargs
  local subcommand_key = fargs[1] or default_key
  local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  local subcommand = M.subcommand_tbl[subcommand_key]
  if not subcommand then
    vim.notify(
      "Minesweeper: Unknown command: " .. subcommand_key,
      vim.log.levels.ERROR
    )
    return
  end
  subcommand.impl(args, opts)
end

return M
