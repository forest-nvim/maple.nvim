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

- Project Based notes (Based on git repository, falls back to directory of folder)
- Global notes that persist no matter what directory you are in.
- Fully configurable keybinds
- Customizable appearance

## Configuration

Here's an example configuration with all available options:

```lua
require('maple').setup({
    -- Appearance
    width = 0.6,        -- Width of the popup (ratio of the editor width)
    height = 0.6,       -- Height of the popup (ratio of the editor height)
    border = 'rounded', -- Border style ('none', 'single', 'double', 'rounded', etc.)
    title = ' maple ',
    title_pos = 'center',
    winblend = 10,       -- Window transparency (0-100)
    show_legend = false, -- Whether to show keybind legend in the UI

    -- Storage
    storage_path = vim.fn.stdpath('data') .. '/maple',

    -- Notes management
    notes_mode = "project",            -- "global" or "project"
    use_project_specific_notes = true, -- Store notes by project

    -- Keymaps (set to nil to disable)
    keymaps = {
        toggle = '<leader>m',      -- Key to toggle Maple
        close = 'q',               -- Key to close the window
        switch_mode = 'm',         -- Key to switch between global and project view
    }
})
```

### Keybinds

The plugin does not set any default keybinds. You must configure them in your setup function. Here are the available keybinds:

- `toggle`: Opens/closes the Maple window
- `close`: Closes the Maple window
- `switch_mode`: Toggles between global and project notes

Contributions and Ideas are always welcome!

## Star History
<picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=forest-nvim/maple.nvim&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=forest-nvim/maple.nvim&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=forest-nvim/maple.nvim&type=Date" />
</picture>
