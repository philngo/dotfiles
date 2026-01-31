local opt = vim.opt

-- Tabs and indentation (default 4, overridden per filetype below)
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smarttab = true
opt.autoindent = true
opt.smartindent = true

-- Line numbers
opt.number = true

-- Search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- No backups or swap
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- No sounds
opt.errorbells = false

-- Scrolling
opt.scrolloff = 5

-- Status and command display
opt.showmode = true
opt.showcmd = true
opt.ruler = true
opt.laststatus = 2

-- Line wrapping
opt.wrap = true
opt.linebreak = true
opt.list = false

-- Command completion
opt.wildmenu = true
opt.wildmode = "longest,list,full"
opt.wildignore:append({
  "*/tmp/*", "*.so", "*.swp", "*.zip", "*.pyc",
  "*/node_modules/*", "*/coverage/*", "*/.tox/*",
  "*/.eggs/*", "*/.cache/*", "*/.DS_Store",
  "*.egg-info/*", "*/build/lib/*.py",
})

-- Color column at 88 and 120+
opt.colorcolumn = "88,120"

-- Text width
opt.textwidth = 88
opt.wrapmargin = 0

-- Clipboard (use system clipboard)
opt.clipboard = "unnamedplus"

-- Backspace behavior
opt.backspace = "indent,eol,start"

-- Allow dashes in words
opt.iskeyword:append("-")

-- Faster updates for git signs etc
opt.updatetime = 250

-- Better splits
opt.splitbelow = true
opt.splitright = true

-- Terminal colors
opt.termguicolors = true
opt.background = "dark"

-- Filetype-specific tab settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "css", "html", "htmldjango", "javascript", "json", "markdown",
              "ruby", "scss", "sql", "terraform", "typescript", "typescriptreact",
              "vue", "yaml", "elixir", "eelixir", "heex" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Python specific
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Spell check for text files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "rst" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- No auto comment insertion
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Filetype associations
vim.filetype.add({
  extension = {
    heex = "heex",
    eex = "eelixir",
    leex = "eelixir",
    sface = "eelixir",
  },
  filename = {
    ["Gemfile"] = "ruby",
    [".prettierrc"] = "json",
    ["mix.lock"] = "elixir",
  },
  pattern = {
    ["*.html"] = "htmldjango",
  },
})
