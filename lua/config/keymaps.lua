-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Tab to cycle between buffers in normal mode
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer", silent = true })

-- Tab to cycle LSP completion options in insert mode
vim.keymap.set("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  else
    return "<Tab>"
  end
end, { expr = true, desc = "Next completion item or tab" })

vim.keymap.set("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  else
    return "<S-Tab>"
  end
end, { expr = true, desc = "Previous completion item or shift-tab" })

-- Open terminal vertically with toggle
local terminal_buf = nil
vim.keymap.set("n", "<leader>h", function()
  if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
    -- Check if buffer is visible in any window
    local found = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == terminal_buf then
        vim.api.nvim_win_close(win, false)
        found = true
        break
      end
    end
    if not found then
      vim.cmd("vsplit | buffer " .. terminal_buf)
    end
  else
    vim.cmd("vsplit | terminal")
    terminal_buf = vim.api.nvim_get_current_buf()
  end
end, { desc = "Toggle terminal vertical", silent = true })

-- Exit terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode", silent = true })
