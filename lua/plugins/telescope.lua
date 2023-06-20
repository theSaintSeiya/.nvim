require('utils')

local build = GetOS() == 'Windows'
    and
    'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    or 'make'

local ex_to_current_file = function()
  local cur_file = vim.fn.expand('%:t')
  vim.cmd.Ex()

  local starting_line = 10 -- line number of the first file
  local lines = vim.api.nvim_buf_get_lines(0, starting_line, -1, false)
  for i, file in ipairs(lines) do
    if (file == cur_file) then
      vim.api.nvim_win_set_cursor(0, { starting_line + i, 0 })
      return
    end
  end
end

return {
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' },
    config = function()
      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>pv', ex_to_current_file)
      vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Project Files' })
      vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Search Git files' })
      vim.keymap.set('n', '<leader>pw', function()
        builtin.grep_string({ search = vim.fn.input('Grep > ') })
      end, { desc = 'Find word' })

      vim.keymap.set('n', '<leader>ph', builtin.help_tags, { desc = 'Search Help' })
      vim.keymap.set('n', '<leader>pg', builtin.live_grep, { desc = 'Search by Grep' })
      vim.keymap.set('n', '<leader>pd', builtin.diagnostics, { desc = 'Search Diagnostics' })

      vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })

      vim.keymap.set('n', '<leader><space>', function()
        builtin.buffers {
          only_cwd = true,
          sort_lastused = true,
        }
      end, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = builtin.file_browser,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      require('telescope').load_extension('fzf')
    end
  },

  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = build,
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>pb", require "telescope".extensions.file_browser.file_browser,
        { desc = 'Project Browse', noremap = true })
    end
  }
}
