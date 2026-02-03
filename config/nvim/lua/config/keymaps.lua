local map = vim.keymap.set

-- ; to : for commands
map("n", ";", ":", { noremap = true })

-- Buffer navigation
map("n", "<C-j>", ":bp<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
map("n", "<C-k>", ":bn<CR>", { noremap = true, silent = true, desc = "Next buffer" })

-- Enter to add new line below
map("n", "<CR>", "o<Esc>", { noremap = true })
map("n", "<S-Enter>", "O<Esc>", { noremap = true })

-- Space to insert space
map("n", "<Space>", "i<Space><Esc>l", { noremap = true })

-- kj to escape
map("i", "kj", "<Esc>", { noremap = true })

-- Leader shortcuts
map("n", "<leader>v", ":e ~/.config/nvim/init.lua<CR>", { desc = "Edit nvim config" })
map("n", "<leader>z", ":e ~/.zshrc<CR>", { desc = "Edit zshrc" })
map("n", "<leader>sv", ":source ~/.config/nvim/init.lua<CR>", { desc = "Source nvim config" })
map("n", "<leader>tw", ":%s/\\s\\+$//<CR>", { desc = "Trim trailing whitespace" })

-- Git branch files (files changed on this branch since diverging from main)
map("n", "<leader>gb", function()
  require("telescope.builtin").git_files({
    prompt_title = "Branch Files (vs main)",
    git_command = { "git", "diff", "--name-only", "main...HEAD" },
    use_git_root = true,
  })
end, { desc = "Git branch files" })

-- Keep cursor position after yank
map("v", "y", "ygv<Esc>", { noremap = true })

-- Keep selection after indent
map("v", ">", ">gv", { noremap = true })
map("v", "<", "<gv", { noremap = true })

-- Clear search highlight with Escape
map("n", "<Esc>", ":noh<CR><Esc>", { noremap = true, silent = true })
