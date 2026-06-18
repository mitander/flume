<div align="center">
  <h1>Flume</h1>
  <p>
    <strong>Small waves. Soft contrast. Readable code.</strong><br>
    Inspired by One Dark, Duskfox and Kanagawa.
  </p>
</div>

<br>

<div align="center">
  <img src="screenshot.png" alt="Flume Theme Screenshot" width="1200">
</div>

## Install

### Neovim

With `lazy.nvim`, point at this directory and load it like a normal colorscheme:

```lua
return {
    dir = vim.fn.expand("~/path/to/flume"),
    name = "flume.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd.colorscheme("flume")
    end,
}
```

Tweaking colors? Reload without restarting Neovim:

```vim
:FlumeReload
```

### Ghostty

Symlink the theme into Ghostty's theme directory:

```bash
mkdir -p ~/.config/ghostty/themes
ln -sf ~/dotfiles/themes/flume/ghostty/flume ~/.config/ghostty/themes/flume
```

Then enable it in `~/.config/ghostty/config`:

```ini
theme = flume
```

### Tmux

Symlink the tmux theme variables into your tmux config directory:

```bash
mkdir -p ~/.tmux
ln -sf ~/path/to/flume/tmux/colors.conf ~/.tmux/flume-theme.conf
```

Then source it before your own status/pane styling:

```tmux
source-file "~/.tmux/flume-theme.conf"
```
