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
map("n", "<leader>md", ":MarkdownPreviewToggle<CR>", { silent = true, desc = "Markdown preview" })

-- Changed files (jj bookmark or git branch diff)
map("n", "<leader>gb", function()
  -- Run from jj repo root so paths are clean (no ../prefixes from subdirectories)
  local root = vim.fn.system("jj root --no-pager 2>/dev/null"):gsub("%s+$", "")
  local jj_cwd = vim.v.shell_error == 0 and root or nil
  local cmd = "jj diff --no-pager --name-only --from 'latest(::@ & ::trunk())' --to @ --color never"
  if jj_cwd then
    cmd = "cd " .. vim.fn.shellescape(jj_cwd) .. " && " .. cmd
  end
  local files = vim.fn.systemlist(cmd .. " 2>/dev/null")
  if vim.v.shell_error == 0 and #files > 0 then
    require("telescope.pickers")
      .new({}, {
        prompt_title = "Changed Files (jj bookmark)",
        finder = require("telescope.finders").new_table({
          results = files,
          entry_maker = function(f)
            return { value = f, display = f, ordinal = f, filename = jj_cwd .. "/" .. f }
          end,
        }),
        sorter = require("telescope.config").values.generic_sorter({}),
        previewer = require("telescope.config").values.file_previewer({}),
      })
      :find()
    return
  end

  -- Fall back to git
  require("telescope.builtin").git_files({
    prompt_title = "Branch Files (vs main)",
    git_command = { "git", "diff", "--name-only", "main...HEAD" },
    use_git_root = true,
  })
end, { desc = "Changed files (jj or git)" })

-- jj aliases
require("which-key").add({ { "<leader>j", group = "jj" } })
map("n", "<leader>js", "<leader>gs", { remap = true, desc = "Changed files in revision (@)" })
map("n", "<leader>jb", "<leader>gb", { remap = true, desc = "Changed files in bookmark (vs trunk)" })

-- Keep cursor position after yank
map("v", "y", "ygv<Esc>", { noremap = true })

-- Keep selection after indent
map("v", ">", ">gv", { noremap = true })
map("v", "<", "<gv", { noremap = true })

-- Clear search highlight with Escape
map("n", "<Esc>", ":noh<CR><Esc>", { noremap = true, silent = true })
