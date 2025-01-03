<h1 align="center">
  Minesweeper.nvim
  <br>
</h1>

<h4 align="center">A simple <a href="https://neovim.io/" target="_blank">Neovim</a> plugin to play minesweeper</h4>

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.8+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

![screenshot](https://github.com/QU4SIMOTO/minesweeper.nvim/blob/main/assets/minesweeper.gif)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

To install `minesweeper.nvim`, you can add the following to your Neovim configuration:

```lua
{ "QU4SIMOTO/minesweeper.nvim" }
```

### Using [Packer](https://github.com/wbthomason/packer.nvim)

Alternatively, if you use Packer, you can install the plugin like this:

```lua
use 'QU4SIMOTO/minesweeper.nvim'
```

## How to Use

### Starting the Game

To start a game of Minesweeper in Neovim, run the following command:

```vim
:Minesweeper
```

This will toggle the the Minesweeper game interface open in a floating window inside Neovim, where you can start playing!

- Move the cursor with (`h`, `j`, `k`, `l`) or arrow keys.
- Use `<Cr>` to select a cell or `f` to flag the cell.

### Minimizing the Game

To minimize the Minesweeper game interface either unfocus the window or use the command:

```vim
:Minesweeper
```

To reopen the game run the same command and the game will resume from where you were.

### Starting a New Game

To start a new game with a randomly generated grid use:

```vim
:Minesweeper new
```

## Testing

### Overview
Minesweeper.nvim uses [MiniTest](https://github.com/echasnovski/mini.test) to run unit tests and ensure that the plugin works as expected. This section will guide you on how to run the tests, lint the code, and format it for consistency.

### Running the Tests

1. **Install Dependencies**: Make sure you have Neovim and the necessary dependencies installed, including make and lua.
2. **Run the Tests**: Use the following command to run the full test suite:

```shell
make test
```

This command will run Neovim in headless mode, meaning without any user interface, and execute the tests defined in the plugin. The output will be displayed in your terminal.

## License

MIT

