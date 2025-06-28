# maple.nvim 🌴

![Screenshot](https://github.com/forest-nvim/maple.nvim/blob/main/assets/screenshot.png?raw=true)

## Features

- 📂 Side panel file tree for easy navigation
- 🏠 Centralized notes storage in `~/.local/share/nvim/maple/notes`
- 🎨 Customizable appearance and keybinds
- 📝 Markdown support with syntax highlighting
- 🚀 Built with plenary.nvim for reliability

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim) (recommended):

```lua
{
  'forest-nvim/maple.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',  -- optional, for file icons
  },
  opts = {
    -- Your configuration here
  }
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'forest-nvim/maple.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',  -- optional
  },
  config = function()
    require('maple').setup({
      -- Your configuration here
    })
  end
}
```

## Configuration

Default configuration with all available options:

```lua
require('maple').setup({
    -- Panel settings
    width = 30,                   -- Width of the side panel
    position = 'left',            -- 'left' or 'right'
    auto_close = false,           -- Auto close when opening a file
    auto_refresh = true,          -- Auto refresh the file tree
    respect_gitignore = true,     -- Respect .gitignore files

    -- File icons
    icons = {
        default = '📄',
        symlink = '🔗',
        folder = {
            default = '📁',
            open = '📂',
            empty = '📁',
            empty_open = '📂',
            symlink = '🔗',
            symlink_open = '🔗',
        },
    },

    -- Keymaps
    keymaps = {
        toggle = '<leader>m',     -- Toggle the side panel
        create_file = 'a',        -- Create a new file
        create_folder = 'd',      -- Create a new folder
        rename = 'r',             -- Rename a file/folder
        delete = 'D',             -- Delete a file/folder
        close = 'q',              -- Close the panel
        refresh = 'R',            -- Refresh the file tree
    },

    -- Notes management
    notes_dir = vim.fn.stdpath('data') .. '/maple/notes',  -- Central notes directory

    -- UI
    highlight_opened_files = true,
    hide_dotfiles = true,
    diagnostics = {
        enable = true,
        show_on_dirs = true,
    },
})
```

## Commands

- `:MapleToggle` - Toggle the notes panel
- `:MapleFocus` - Focus the notes panel
- `:MapleFindFile` - Find and open a note file
- `:MapleNewFile` - Create a new note


## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
