local M = {}
local default_key = "toggle"

---@class MinesweeperSubcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback

---@type table<string, MinesweeperSubcommand>
M.subcommand_tbl = {
  new = {
    impl = function(args)
      if #args > 2 then
        vim.notify("Minesweeper new: too many arguments", vim.log.levels.ERROR)
        return
      end
      if args[2] and args[2]:match("%D") then
        vim.notify(
          "Minesweeper new: seed argument must be and integer",
          vim.log.levels.ERROR
        )
        return
      end
      require("minesweeper"):new_game(args[1], args[2] and tonumber(args[2]))
    end,
  },
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
  sweep = {
    impl = function(args)
      if #args < 2 then
        vim.notify(
          "Minesweeper sweep: not enough arguments",
          vim.log.levels.ERROR
        )
        return
      end
      if #args > 2 then
        vim.notify("Minesweeper sweep: too many argument", vim.log.levels.ERROR)
        return
      end
      local row = tonumber(args[1])
      local col = tonumber(args[2])

      if not row then
        vim.notify(
          "Minesweeper sweep: row must be a number",
          vim.log.levels.ERROR
        )
        return
      end
      if not col then
        vim.notify(
          "Minesweeper sweep: col must be a number",
          vim.log.levels.ERROR
        )
        return
      end

      require("minesweeper"):show({
        row = row,
        col = col,
      })
    end,
  },
  flag = {
    impl = function(args)
      if #args < 2 then
        vim.notify(
          "Minesweeper sweep: not enough arguments",
          vim.log.levels.ERROR
        )
        return
      end
      if #args > 2 then
        vim.notify("Minesweeper sweep: too many argument", vim.log.levels.ERROR)
        return
      end
      local row = tonumber(args[1])
      local col = tonumber(args[2])

      if not row then
        vim.notify(
          "Minesweeper sweep: row must be a number",
          vim.log.levels.ERROR
        )
        return
      end
      if not col then
        vim.notify(
          "Minesweeper sweep: col must be a number",
          vim.log.levels.ERROR
        )
        return
      end

      require("minesweeper"):flag({
        row = row,
        col = col,
      })
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
