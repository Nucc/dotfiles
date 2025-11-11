require("config.keymaps.keymap-helper")
require("config.keymaps.neotree-keymaps")
require("config.keymaps.cmp-keymaps")

-- Function to jump to definition with LSP check
function _G.safe_lsp_definition()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP client attached", vim.log.levels.WARN)
    return
  end
  require("fzf-lua").lsp_definitions()
end

-- Map gd to LSP definitions with safety check
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua _G.safe_lsp_definition()<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "\xF4\x80\x83\xA1", "^", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<M-Left>", "b", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<M-Right>", "w", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-M-Up>", ":m .-2<CR>==", { desc = "Move selection up", noremap = true })
vim.api.nvim_set_keymap("n", "<C-M-Down>", ":m .+1<CR>==", { desc = "Move selection down", noremap = true })
vim.api.nvim_set_keymap("v", "<C-M-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection Down", noremap = true })
vim.api.nvim_set_keymap("v", "<C-M-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection Up", noremap = true })

vim.api.nvim_set_keymap("n", "\xF4\x80\x84\x87", "<C-u>", { noremap = true }) -- Cmd-Shift-Up
vim.api.nvim_set_keymap("n", "\xF4\x80\x84\x88", "<C-d>", { noremap = true }) -- Cmd-Shift-Down

bind_niv("<Del>", '"_x', nil, '"_d') -- Delete
bind_niv("<BS>", '"_X', nil, '"_d') -- Backspace
bind_all("\xF4\x80\x81\x8C", ":lua ToggleLineNumbers()<CR>", { keep_mode = true }) -- CMD-SHIFT-L
bind_all("\xF4\x80\x81\xA1", "ggVG") -- # CMD-A
bind_niv("\xF4\x80\x81\xB3", ":w<CR>", "<Esc>:w<CR>l", "<Esc>:w<CR>") -- CMD-S
bind_niv("\xF4\x80\x80\xAF", "gcc", "<Esc>gcc", "gc", { noremap = false }) -- CMD-/
bind_niv("\xF4\x80\x81\xA3", '"+yy', '<Esc>"+yy', 'mz"+y`z') -- CMD-C
bind_niv("\xF4\x80\x81\xA4", '"_dd', '<Esc>"_dd', '"_d') -- CMD-D
bind_all("\xF4\x80\x81\xAE", ":enew<CR>") -- CMD-N
bind_all("\xF4\x80\x81\xB0", ":FzfLua files<CR>") -- CMD-P
bind_all("\xF4\x80\x81\x90", ":FzfLua commands<CR>") -- CMD-Shift-P
bind_all("\xF4\x80\x81\xB7", ":bd<CR>") -- CMD-W
bind_all("\xF4\x80\x81\x86", ":FzfLua live_grep<CR>") -- CMD-SHIFT-F
bind_all("\xF4\x80\x81\x88", ":%s///g<Left><Left><Left>") -- CMD-SHIFT-H
bind_all("\xF4\x80\x81\x93", ":FzfLua grep_cword<CR>") -- CMD-SHIFT-S
bind_all("\xF4\x80\x81\xBA", "u") -- CMD-Z
bind_all("\xF4\x80\x81\x9A", "<cmd>redo<CR>") -- CMD-SHIFT-Z
bind_all("\xF4\x80\x81\x84", '"-yy"-p') -- CMD-SHIFT-D {key = 'D', mods = 'Command|Shift', chars = '􀁄'}, # U+100044: \xF4\x80\x81\x84
bind_all("\xF4\x80\x81\xBB", ":bp<CR>") -- CMD-{
bind_all("\xF4\x80\x81\xBD", ":bnext<CR>") -- CMD-}
bind_niv("\xF4\x80\x80\xBC", "<<", "<Esc><<", "<") -- CMD-SHIFT-<
bind_niv("\xF4\x80\x80\xBE", ">>", "<Esc>>>", ">") -- CMD-SHIFT->
bind_niv("\xF4\x80\xA2\xB0", "<cmd>lua _G.safe_lsp_definition()<CR>", nil, nil) -- CMD-OPT-Down
bind_niv("\xF4\x80\x83\x9F", "gg", "<Esc>gg", "gg") -- CMD-Down
bind_niv("\xF4\x80\x83\xA0", "G", "<Esc>G", "G") -- CMD-Up
-- bind_niv("\xF4\x80\xA2\xB0", "<cmd>lua _G.safe_lsp_definition()<CR>", nil, nil) -- CMD-OPT-Down
bind_all("\xF4\x80\x81\xB4", ":FzfLua buffers<CR>") -- CMD-T
bind_all("\xF4\x80\x81\x8F", "<cmd>Neotree filesystem reveal left<CR>") -- CMD-SHIFT-O
bind_all(
  "\xF4\x80\x81\x83",
  '<cmd>let @+ = substitute(expand("%:p"), getcwd() .. "/", "", "")<CR>',
  { keep_mode = true }
) -- Cmd-Shift-C
bind_all("\xF4\x80\x83\x88", "o", { noremap = false }) -- CMD-Enter
bind_all("\xF4\x80\x83\xB0", "O", { noremap = false }) -- CMD-Shift-Enter
bind_all("\xF4\x80\x81\x8F", "<cmd>Neotree filesystem reveal left<CR>") -- CMD-SHIFT-O
bind_niv("\xF4\x80\x83\x89", '"_d^', '<Esc>l"_di', nil, { noremap = false }) -- CMD-Backspace
bind_niv("\xF4\x80\x83\x8A", '"_d$', '<Esc>l"_d$a', nil, { noremap = false }) -- CMD-Backspace
bind_all("\xF4\x80\x81\x90", ":FzfLua commands<CR>") -- {key = 'P', mods = 'Command|Shift', chars = '􀁐'}, # U+100050: \xF4\x80\x81\x90
bind_all("\xF4\x80\x81\x94", ":vsplit<CR>:enew<CR>") -- Cmd-Shift-T
bind_all("\xF4\x80\x81\x87", ":LazyGit<CR>")
bind_all("\xF4\x80\x81\x97", ":bufdo bd<CR>") -- Cmd-Shift-W
bind_niv("\xF4\x80\x80\xBF", ":ChatGPT<CR>", "<Esc>:ChatGPT<CR>", ":'<,'>ChatGPTRun explain_code<CR>") -- Cmd-Shift-?
bind_all("\xF4\x80\x81\x85", ":ChatGPTEditWithInstructions<CR>") -- Cmd-Shift-E

-- map("n", "¤[1;117", ":silent !tmux split-window -h<CR>", { noremap = true, silent = true })
-- map("n", "¤[1;18R", ':w<CR>:lua require("custom.tmux_commands").repeat_command()<CR>')
-- map("n", "<C-CR>", ':w<CR>:lua require("custom.tmux_commands").up_enter()<CR>', { noremap = true })

bind_all("\xF4\x80\xA2\xAF", "<cmd>FzfLua lsp_references<CR>")
bind_all("\xF4\x80\xA2\xB1", "<C-O>")
bind_all("\xF4\x80\xA2\xB2", "<C-I>")

bind_all("\xF4\x80\x81\xA6", "/") -- CMD-F
bind_all("\xF4\x80\x80\xA7", ":vsplit<CR>") -- CMD-'
bind_all("\xF4\x80\x80\xBB", ":split<CR>") -- CMD-;
bind_all("\xF4\x80\x81\xA6", "/")
bind_all("\xF4\x80\xB3\x8C", "<cmd>ClaudeCode<CR>")
