# maple.nvim 🌴

A powerful file tree explorer for Neovim inspired by nvim-tree, designed for organizing notes and folders with hierarchical navigation.

## Features

- 🌳 **Hierarchical file tree** with expand/collapse functionality
- 📂 **Tree navigation** with visual indicators and indentation
- 📝 **Smart file operations** - create, delete, and manage files/folders
- 🔍 **Parent/child navigation** similar to nvim-tree
- 🗂️ **Directory state persistence** - remembers expanded folders
- 📄 **Auto .md extension** for new files
- 🏠 **Centralized storage** in your nvim data directory
- ❓ **Built-in help system** with `g?`

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'your-username/maple.nvim',
  config = function()
    require('maple').setup()
  end
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'your-username/maple.nvim',
  config = function()
    require('maple').setup()
  end
}
```

## Configuration

```lua
require('maple').setup({
  keybind = '<leader>m',  -- Change the toggle keybind (default: <leader>m)
  width = 35,            -- Sidebar width (default: 35)
  icons = {
    folder = '📁',
    folder_open = '📂',
    folder_closed = '▶',
    file = '📄'
  },
  keymaps = {
    create_file = 'a',
    create_folder = 'A',
    delete = 'd',
    close = 'q',
    refresh = 'r',
    expand_all = 'E',
    collapse_all = 'W',
    parent = 'P'
  }
})
```

## Usage

### Basic Navigation

- Press `<leader>m` to toggle the file tree sidebar
- The tree shows your file hierarchy with visual indicators
- **Directories** show expand/collapse arrows (▶/📂)
- **Files** are indented under their parent directories

### Keybindings

When the file tree is focused, use these keys:

#### Navigation

- `<CR>` - Open file or toggle directory expansion
- `o` - Open file in new split (files only)
- `l` - Expand directory or open file
- `h` - Collapse directory or go to parent
- `P` - Go to parent directory

#### Tree Operations

- `E` - Expand all directories
- `W` - Collapse all directories
- `r` - Refresh the tree

#### File Operations

- `a` - Create new file (in current directory)
- `A` - Create new directory (in current directory)
- `d` - Delete file or directory (with confirmation)

#### Other

- `q` - Close the file tree
- `g?` - Show help with all keybindings

### Tree Structure

The file tree displays:

- **Indentation** to show hierarchy levels
- **Visual indicators** for expandable folders
- **Smart sorting** - directories first, then files (case-insensitive)
- **State persistence** - expanded folders stay expanded

## Commands

- `:MapleToggle` - Toggle the file tree sidebar

## File Organization

- Files are stored in `~/.local/share/nvim/maple/notes` (or equivalent on your system)
- New files automatically get a `.md` extension if no extension is provided
- The tree structure mirrors your actual file system hierarchy
- Directory expansion state is remembered during your session

## Inspiration

This plugin is inspired by [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) and adopts similar navigation patterns and tree management concepts while remaining focused on note-taking workflows.
