# maple.nvim

A simple Neovim plugin for managing project and system based notes
![image](https://github.com/user-attachments/assets/62cb554c-ac8c-4973-a20d-76bf7440a0d2)

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({
  'forest-nvim/maple.nvim',
  config = function()
    require('maple').setup({
      -- Your configuration options here
    })
  end
})
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'forest-nvim/maple.nvim',
  opts = {
      -- Your configuration options here
    }
}
```

## Features

- **Project-scoped notes** — Based on git repository, falls back to directory
- **Global notes** — Persist no matter what directory you are in
- **Markdown checkbox support** — Toggle `- [ ]` / `- [x]` with a keymap
- **Telescope integration** — Search across all notes with `:MapleSearch`
- **Configurable highlights** — Custom highlight groups for full theming control
- **Winbar** — Mode indicator and word count in the window bar
- **Fully configurable keybinds** — All features exposed as commands, bind them however you like
- **Zero dependencies**

## Commands

| Command | Description |
|---|---|
| `:MapleToggle` | Toggle the notes window (uses configured `open_style`) |
| `:MapleToggleFloat` | Toggle notes in a floating window |
| `:MapleToggleSplit` | Toggle notes in a horizontal split |
| `:MapleToggleVsplit` | Toggle notes in a vertical split |
| `:MapleToggleBuffer` | Toggle notes in the current buffer |
| `:MapleClose` | Close the notes window |
| `:MapleSwitchMode` | Toggle between global and project notes |
| `:MapleToggleCheckbox` | Toggle checkbox on current line |
| `:MapleAddCheckbox` | Insert a new checkbox below cursor |
| `:MapleSearch [grep]` | Search notes with Telescope |

## Configuration

```lua
require('maple').setup({
    -- Appearance
    width = 0.6,
    height = 0.6,
    border = 'rounded',
    title = ' maple ',
    title_pos = 'center',
    winblend = 10,
    show_winbar = true,
    relative_number = false,
    open_style = 'float', -- 'float', 'split', 'vsplit', or 'buffer'

    -- Storage
    storage_path = vim.fn.stdpath('data') .. '/maple',

    -- Notes management
    notes_mode = "project",
    use_project_specific_notes = true,

    -- Custom highlight overrides
    highlights = {},
})
```

### Keybinds

The plugin does not set any keybinds. All features are exposed as commands — bind them however you like:

```lua
vim.keymap.set('n', '<leader>mt', '<cmd>MapleToggle<CR>', { desc = 'Toggle Maple Notes' })
vim.keymap.set('n', '<leader>mh', '<cmd>MapleToggleSplit<CR>', { desc = 'Toggle notes in split' })
vim.keymap.set('n', '<leader>mv', '<cmd>MapleToggleVsplit<CR>', { desc = 'Toggle notes in vsplit' })
vim.keymap.set('n', '<leader>mb', '<cmd>MapleToggleBuffer<CR>', { desc = 'Toggle notes in buffer' })
vim.keymap.set('n', '<leader>ms', '<cmd>MapleSwitchMode<CR>', { desc = 'Switch notes mode' })
vim.keymap.set('n', '<leader>mc', '<cmd>MapleToggleCheckbox<CR>', { desc = 'Toggle checkbox' })
vim.keymap.set('n', '<leader>ma', '<cmd>MapleAddCheckbox<CR>', { desc = 'Add checkbox' })
vim.keymap.set('n', '<leader>mf', '<cmd>MapleSearch<CR>', { desc = 'Search notes' })
vim.keymap.set('n', '<leader>mg', '<cmd>MapleSearch grep<CR>', { desc = 'Grep notes' })
```

### Telescope Integration

Requires [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (optional):

```lua
require('telescope').load_extension('maple')
```

Then use `:Telescope maple` to browse notes or `:Telescope maple grep` to search note contents.

Contributions and Ideas are always welcome!

## Star History
<picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=forest-nvim/maple.nvim&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=forest-nvim/maple.nvim&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=forest-nvim/maple.nvim&type=Date" />
</picture>
