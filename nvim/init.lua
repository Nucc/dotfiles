-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

function ToggleLineNumbers()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  else
    vim.wo.relativenumber = true
  end
end

vim.wo.relativenumber = false

-- Mason and LSP configuration is handled by LazyVim
-- Remove manual Mason setup to avoid conflicts

-- vim.api.nvim_create_autocmd("BufLeave", {
--   callback = function(args)
--     local bufnr = args.buf
--
--     -- Never touch special buffers (e.g., quickfix, help, terminal, neo-tree, etc.)
--     local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
--
--     if buftype ~= "" then
--       return
--     end
--
--     -- Explicitly exclude Neo-tree buffers by name pattern
--     local bufname = vim.api.nvim_buf_get_name(bufnr)
--     if bufname ~= "" and bufname:match("neo%-tree://") then
--       return
--     end
--
--     -- Only target unnamed, unmodified, completely empty buffers
--     local modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })
--     local line_count = vim.api.nvim_buf_line_count(bufnr)
--     if bufname == "" and not modified and line_count <= 1 then
--       pcall(vim.api.nvim_buf_delete, bufnr, {})
--     end
--   end,
-- })
