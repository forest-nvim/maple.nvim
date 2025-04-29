# maple.nvim

A simple Neovim plugin for managing project based notes
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
  config = function()
    require('maple').setup({
      -- Your configuration options here
    })
  end
}
```

## Features
- Project Based notes (Based on git repository, falls back to directory of folder)
- Global notes that persist no matter what directory you are in.

### Default keybinds:
- <leader>m: Toggle Maple
- q: quit
- m: toggle mode (Project vs Global)

Contributions and Ideas are always welcome!


