local vim = vim
local M = {}

local function log(string)
  local file = io.open("debug.log", "a")
  file:write(string .. "\n")
  file:close()
end

M.target_pane = nil
M.pane_marker = "🥖"
M.last_command = ""

local function shell_exec(command)
  local handle = io.popen(command)
  local output = handle:read("*a")
  handle:close()
  return output:gsub("^%s*(.-)%s*$", "%1")
end

local function get_pane_info()
  local output = shell_exec("tmux list-panes -F '#{pane_index}:#{pane_id}:#{pane_pid}:#{pane_current_command}'")

  local pane_array = {}
  for line in string.gmatch(output, "([^\n]+)") do
    local pane_index, pane_id, pane_pid, pane_command = line:match("([^:]*):([^:]*):([^:]*):([^:]*)")
    table.insert(pane_array, {
      index = pane_index,
      id = pane_id,
      command = pane_command,
      pid = pane_pid,
    })
  end

  log("Panes: " .. vim.inspect(pane_array))
  return pane_array
end

local function get_target_pane_info()
  local all_panes = get_pane_info()
  for _, pane in ipairs(all_panes) do
    if pane.id == M.target_pane then
      return pane
    end
  end
  return nil
end

local function send_to_tmux_pane(target_pane, command)
  local pane_info = get_target_pane_info()
  local fg_process = pane_info.command
  local shell_pid = pane_info.pid

  -- local quit_keys = {
  --   ["vim"] = "<C-c><ESC>:qall!<ENTER>",
  --   ["nvim"] = "<C-c><ESC>:qall!<ENTER>",
  --   ["less"] = "q",
  -- }

  if shell_pid ~= "" and fg_process ~= "bash" and fg_process ~= "fish" and fg_process ~= "zsh" then
    -- local quit_key = quit_keys[fg_process] or "C-c"
    -- shell_exec(string.format("tmux send-keys -t %s '%s'", target_pane, quit_keys))

    local kill_command = string.format("pgrep -P %s | xargs kill -TERM", shell_pid)
    shell_exec(kill_command)
  else
    -- in case there is something already typed in the terminal
    shell_exec(string.format("tmux send-keys -t %s '%s'", target_pane, "C-c"))
  end

  local tmux_command = string.format("tmux send-keys -t%s '%s' C-m", target_pane, command)
  shell_exec(tmux_command)
end

local function mark_pane(pane_id, marker)
  local tmux_border_format = shell_exec("tmux show-option -g pane-border-format")
  local new_tmux_border_format = string.gsub(tmux_border_format, "#P", marker .. "#P", 1)
  shell_exec(string.format("tmux set-option -p -t %s %s", pane_id, new_tmux_border_format))
end

local function unmark_pane(pane_id)
  local tmux_border_format = shell_exec("tmux show-option -g pane-border-format")
  shell_exec(string.format("tmux set-option -p -t %s %s", pane_id, tmux_border_format))
end

-- local function choose_tmux_pane()
--   local current_pane_id = os.getenv("TMUX_PANE")
--   local panes = get_pane_info()
--
--   local menu_items = {
--     "0 - New Pane (or ENTER)",
--   }
--
--   for _, pane in ipairs(panes) do
--     if pane.id ~= current_pane_id then
--       table.insert(menu_items, string.format("%s - Pane ID: %s, Process: %s", pane.index, pane.id, pane.command))
--       unmark_pane(pane.id)
--     end
--   end
--
--   local selection = 0
--   log("Pane Map: " .. vim.inspect(pane_map))
--
--   if #menu_items > 0 then
--     selection = vim.fn.inputlist(menu_items)
--   end
--
--   log("Selection: " .. vim.inspect(selection))
--   log("Selection (string): " .. vim.inspect(tostring(selection)))
--   log("pane_map[selection]: " .. vim.inspect(pane_map[selection]))
--   log("pane_map[tostring(selection)]: " .. vim.inspect(pane_map[tostring(selection)]))
--
--   local new_target_pane = nil
--
--   if selection == 0 then
--     log("creating new pane")
--     new_target_pane = shell_exec('tmux split-window -hdP -F "#{pane_id}" -c "$(pwd)"')
--   elseif selection > 1 then
--     log("picking existing pane")
--     new_target_pane = pane_map[tostring(selection)]
--   else
--     log("ooops" .. selection)
--   end
--
--   log("new_target_pane " .. vim.inspect(new_target_pane))
--
--   if not new_target_pane then
--     -- vim.api.nvim.err_writeln("Error setting new target pane")
--     vim.api.nvim_out_write("Error setting target pane\n")
--   end
--
--   mark_pane(new_target_pane, M.pane_marker)
--
--   return new_target_pane
-- end

local function open_new_pane()
  return shell_exec('tmux split-window -hdP -F "#{pane_id}" -c "$(pwd)"')
end

local function choose_tmux_pane()
  local current_pane_id = os.getenv("TMUX_PANE")
  local pane_list = {}

  for _, pane in ipairs(get_pane_info()) do
    if pane.id ~= current_pane_id then
      pane_list[pane.index] = pane
    end
  end

  local prompt_msg = "Choose a tmux pane:\n"
  for pane_index, pane in pairs(pane_list) do
    prompt_msg = prompt_msg .. string.format("Pane %s (%s)\n", pane_index, pane.command)
  end

  local selection = 0
  local selected_pane = 0

  if next(pane_list) then
    selection = vim.fn.input(prompt_msg)
  end

  if selection == "" then
    selected_pane = open_new_pane()
  else
    selected_pane = pane_list[selection]
  end

  return selected_pane and selected_pane.id or nil
end

-- Public functions ------------------------------------------------------------

function M.set_target_pane()
  M.target_pane = nil
  for _, pane in ipairs(get_pane_info()) do
    unmark_pane(pane.id)
  end

  M.target_pane = choose_tmux_pane()
  mark_pane(M.target_pane, M.pane_marker)
end

function M.repeat_command()
  if M.last_command ~= "" and M.target_pane then
    send_to_tmux_pane(M.target_pane, M.last_command)
  else
    vim.api.nvim_err_writeln("Error: must have a target pane and a command to repeat")
  end
end

function M.send_command(command)
  M.last_command = command
  send_to_tmux_pane(M.target_pane, command)
end

function M.prompt_and_send_command()
  if M.target_pane then
    local user_command = vim.fn.input("Command to run: ")
    send_to_tmux_pane(M.target_pane, user_command)
    M.last_command = user_command
  else
    vim.api.nvim_err_writeln("No target pane set.")
  end
end

function M.up_enter()
  shell_exec(string.format("tmux send-keys -t%s C-c Up ENTER", M.target_pane))
end

function M.send_page_key_to_tmux(key)
  local copy_mode_command = string.format("tmux copy-mode -t%s -e", M.target_pane)
  shell_exec(copy_mode_command)

  local page_command = string.format("tmux send-keys -t%s '%s'", M.target_pane, key)
  shell_exec(page_command)
end

return M
