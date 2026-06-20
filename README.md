<div align="center">
  <!-- <h1>flume.nvim</h1> -->
  <p>
    <strong>Organic synthesis. Soft contrast. Resonant code.</strong><br>
    Inspired by One Dark, Duskfox and Kanagawa.
  </p>
</div>

<br>

<div align="center">
  <img src="screenshot.png" alt="Flume Theme Screenshot" width="1200">
</div>

## Install

### Neovim

#### Install from GitHub

Using `lazy.nvim`:

```lua
{
    "mitander/flume.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        transparent = false, -- Set to true to disable background colors
        overrides = {},      -- Map highlight groups or colors to override
    },
    config = function(_, opts)
        require("flume").setup(opts)
        vim.cmd.colorscheme("flume")
    end,
}
```

#### Local Clone

```lua
{
    "mitander/flume.nvim",
    dir = "~/path/to/flume.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        transparent = false,
    },
    config = function(_, opts)
        require("flume").setup(opts)
        vim.cmd.colorscheme("flume")
    end,
}
```

### Hacking on the theme

If you are modifying colors or configurations:

1. Edit colors in `lua/flume/palette.lua`.
2. Reload theme with `:FlumeReload`.
3. Compile the theme for other applications with `:FlumeCompile`, or from a shell:

```sh
nvim --headless -c "lua require('flume.compiler').compile_all()" -c "qa"
```

4. Launch the Ghostty screenshot environment: `./scripts/screenshot-window.sh`.

## Extras

Flume includes theme configurations for other applications under the `extras/` directory.

### Ghostty

Symlink the generated theme into Ghostty's theme directory:

```bash
mkdir -p ~/.config/ghostty/themes
ln -sf <flume_dir>/extras/ghostty/flume ~/.config/ghostty/themes/flume
```

Then enable it in `~/.config/ghostty/config`:

```ini
theme = flume
```

### Tmux

Symlink the tmux theme variables into your tmux config directory:

```bash
mkdir -p ~/.tmux
ln -sf <flume_dir>/extras/tmux/colors.conf ~/.tmux/flume-theme.conf
```

Then source it in your `~/.tmux.conf`:

```tmux
source-file "~/.tmux/flume-theme.conf"
```

### LSD

Symlink the lsd theme variables:

```bash
mkdir -p ~/.config/lsd
ln -sf <flume_dir>/extras/lsd/colors.yaml ~/.config/lsd/colors.yaml
```
