function map(mode, key, command, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, key, command, options)
end

function bind_all(key, command, opts)
  local i_postfix = ""
  if opts and opts.keep_mode ~= nil then
    i_postfix = i_postfix .. "a"
    opts.keep_mode = nil
  end

  map("n", key, command, opts)
  map("v", key, "<Esc>" .. command, opts)
  map("i", key, "<Esc>" .. command .. i_postfix, opts)
end

function bind_niv(key, command_n, command_i, command_v, opts)
  if command_n then
    map("n", key, command_n, opts)
  end

  if command_v then
    map("v", key, command_v, opts)
  end

  if command_i then
    map("i", key, command_i, opts)
  end
end
