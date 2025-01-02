local command = require("minesweeper.command")

vim.api.nvim_create_user_command("Minesweeper", command.cmd, {
  nargs = "*",
  desc = "Minesweeper command",
  complete = function(arg_lead, cmdline, _)
    local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Minesweeper[!]*%s(%S+)%s(.*)$")
    if subcmd_key
        and subcmd_arg_lead
        and command.subcommand_tbl[subcmd_key]
        and command.subcommand_tbl[subcmd_key].complete
    then
      -- The subcommand has completions. Return them.
      return command.subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
    end

    -- Check if cmdline is a subcommand
    if cmdline:match("^['<,'>]*Minesweeper[!]*%s+%w*$") then
      local subcommand_keys = vim.tbl_keys(command.subcommand_tbl)
      return vim.iter(subcommand_keys)
          :filter(function(key)
            return key:find(arg_lead) ~= nil
          end)
          :totable()
    end
  end,
  bang = false,
})

