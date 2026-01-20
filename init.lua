-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- global
vim.opt.tabstop = 4 -- a real tab is 4 spaces
vim.opt.shiftwidth = 4 -- indentation amount for >>, <<, autoindent
vim.opt.softtabstop = 4 -- number of spaces a <Tab> counts for while editing
vim.opt.expandtab = true -- use spaces instead of tab characters
-- if at column 1 and not on the first line, go up (count) lines then to column 1
vim.keymap.set("n", "h", function()
  local col = vim.fn.col(".")
  local line = vim.fn.line(".")
  if col == 1 and line > 1 then
    return tostring(vim.v.count1) .. "k0"
  end
  return "h"
end, { expr = true, noremap = true })
