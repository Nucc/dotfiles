require("config.keymaps.keymap-helper")
require("config.keymaps.neotree-keymaps")
require("config.keymaps.cmp-keymaps")

vim.api.nvim_set_keymap("n", "¤[1;116L", "^", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<M-Left>", "b", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<M-Right>", "w", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-M-Up>", ":m .-2<CR>==", { desc = "Move selection up", noremap = true })
vim.api.nvim_set_keymap("n", "<C-M-Down>", ":m .+1<CR>==", { desc = "Move selection down", noremap = true })
vim.api.nvim_set_keymap("v", "<C-M-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection Down", noremap = true })
vim.api.nvim_set_keymap("v", "<C-M-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection Up", noremap = true })

bind_niv("<Del>", '"_x', nil, '"_d') -- Delete
bind_niv("<BS>", '"_X', nil, '"_d') -- Backspace
bind_all("¤[1;38L", ":lua ToggleLineNumbers()<CR>", { keep_mode = true }) -- CMD-SHIFT-L
bind_all("¤[1;1A", "ggVG") -- # CMD-A
bind_niv("¤[1;19S", ":w<CR>", "<Esc>:w<CR>l", "<Esc>:w<CR>") -- CMD-S
bind_niv("¤[1;53/", "gcc", "<Esc>gcc", "gc", { noremap = false }) -- CMD-/
bind_niv("\xF4\x80\x81\xA3", "yy", "<Esc>yy", "mzy`z") -- CMD-C
bind_niv("¤[1;4D", '"_dd', '<Esc>"_dd', '"_d') -- CMD-D
bind_all("¤[1;14N", ":enew<CR>") -- CMD-N
bind_all("¤[1;16P", ":Telescope find_files<CR>") -- CMD-P
bind_all("¤[1;23W", ":bd<CR>") -- CMD-W
bind_all("¤[1;32F", ":Telescope live_grep<CR>") -- CMD-SHIFT-F
bind_all("¤[1;45S", ":Telescope grep_string<CR>") -- CMD-SHIFT-S
bind_all("¤[1;26Z", "u") -- CMD-Z
bind_all("¤[1;52Z", "<cmd>redo<CR>") -- CMD-SHIFT-Z
bind_all("􀁄", '"-yy"-p') -- CMD-SHIFT-D {key = 'D', mods = 'Command|Shift', chars = '􀁄'}, # U+100044: \xF4\x80\x81\x84
bind_all("¤[1;102{", ":bp<CR>") -- CMD-{
bind_all("¤[1;103}", ":bnext<CR>") -- CMD-}
bind_all("¤[1;104<", "<<") -- CMD-SHIFT-<
bind_all("¤[1;105>", ">>") -- CMD-SHIFT->
bind_niv("¤[1;106D", "<cmd>lua vim.lsp.buf.definition()<CR>", nil, nil) -- CMD-OPT-Down
bind_all("\xF4\x80\x83\x9F", "gg") -- CMD-Down
bind_all("\xF4\x80\x83\xA0", "G") -- CMD-Up
bind_niv("\xF4\x80\xA2\xB0", "<cmd>lua vim.lsp.buf.definition()<CR>", nil, nil) -- CMD-OPT-Down
bind_all("¤[1;20T", ":Telescope buffers<CR>") -- CMD-T
bind_all("¤[1;41O", "<cmd>Neotree filesystem reveal left<CR>") -- CMD-SHIFT-O
bind_all("¤[1;29C", '<cmd>let @+ = substitute(expand("%:p"), getcwd() .. "/", "", "")<CR>', { keep_mode = true }) -- Cmd-Shift-C
bind_all("¤[1;110E", "o", { noremap = false }) -- CMD-O
bind_all("¤[1;111E", "O", { noremap = false }) -- CMD-SHIFT-O
bind_niv("¤[1;112B", '"_d^', '<Esc>l"_di', nil, { noremap = false }) -- CMD-Backspace
bind_niv("¤[1;114D", '"_d$', '<Esc>l"_d$a', nil, { noremap = false }) -- CMD-Backspace
bind_all("\xF4\x80\x81\x90", ":Telescope commands<CR>") -- {key = 'P', mods = 'Command|Shift', chars = '􀁐'}, # U+100050: \xF4\x80\x81\x90
bind_all("\xF4\x80\x81\x94", ":vsplit<CR>:enew<CR>") --
bind_all("\xF4\x80\x93\x87", "<C-u>")
bind_all("\xF4\x80\x93\x88", "<C-d>")

map("n", "¤[1;117", ":silent !tmux split-window -h<CR>", { noremap = true, silent = true })
map("n", "¤[1;18R", ':w<CR>:lua require("custom.tmux_commands").repeat_command()<CR>')
map("n", "<C-CR>", ':w<CR>:lua require("custom.tmux_commands").up_enter()<CR>', { noremap = true })

bind_all("\xF4\x80\xA2\xB0", "<cmd>Telescope lsp_definitions<CR>", { noremap = true })
map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "Go to definition", noremap = true })

bind_all("\xF4\x80\xA2\xAF", "<cmd>Telescope lsp_references<CR>")
