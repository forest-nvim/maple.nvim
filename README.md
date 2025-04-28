# maple.nvim

A simple Neovim plugin for managing todo lists in a popup window.

## Features

- Create, toggle, and delete todo items
- Persistent storage across Neovim sessions
- Simple and intuitive interface
- Configurable appearance and keybindings

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({
  'forest.nvim/maple.nvim',
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
  'username/maple.nvim',
  config = function()
    require('maple').setup({
      -- Your configuration options here
    })
  end
}
```

## Configuration

maple.nvim comes with sensible defaults, but you can customize it to your liking:

```lua
require('maple').setup({
  -- Appearance
  width = 0.6,        -- Width of the popup (ratio of the editor width)
  height = 0.6,       -- Height of the popup (ratio of the editor height)
  border = 'rounded', -- Border style ('none', 'single', 'double', 'rounded', etc.)
  title = ' Maple Todo ',
  title_pos = 'center',
  winblend = 10,      -- Window transparency (0-100)

  -- Storage
  storage_path = vim.fn.stdpath('data') .. '/maple-todo.json',

  -- Keymaps
  keymaps = {
    add = 'a',
    toggle = 'x',
    delete = 'd',
    close = {'q', '<Esc>'}
  }
})
```

## Usage

Open the todo list with the command:

```
:mapleTodo
```

### Keybindings

Inside the todo window (default keys, can be configured):

- `a`: Add a new todo item
- `x`: Toggle completion status of the current todo
- `d`: Delete the current todo
- `q` or `<Esc>`: Close the todo window

## License

MIT
