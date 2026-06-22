local palette = require("flume.palette").colors
local M = {}

-- Helper to convert hex to RGB
local function hex_to_rgb(hex)
    hex = hex:gsub("#", "")
    return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

-- Initialize xterm-256 color lookup table
local xterm_palette = {}
local ansi_colors = {
    { 0, 0, 0 },
    { 128, 0, 0 },
    { 0, 128, 0 },
    { 128, 128, 0 },
    { 0, 0, 128 },
    { 128, 0, 128 },
    { 0, 128, 128 },
    { 192, 192, 192 },
    { 128, 128, 128 },
    { 255, 0, 0 },
    { 0, 255, 0 },
    { 255, 255, 0 },
    { 0, 0, 255 },
    { 255, 0, 255 },
    { 0, 255, 255 },
    { 255, 255, 255 },
}
for i = 1, 16 do
    xterm_palette[i - 1] = ansi_colors[i]
end
local steps = { 0, 95, 135, 175, 215, 255 }
for r = 0, 5 do
    for g = 0, 5 do
        for b = 0, 5 do
            local idx = 16 + 36 * r + 6 * g + b
            xterm_palette[idx] = { steps[r + 1], steps[g + 1], steps[b + 1] }
        end
    end
end
for g = 0, 23 do
    local val = 8 + 10 * g
    local idx = 232 + g
    xterm_palette[idx] = { val, val, val }
end

local function rgb_distance(r1, g1, b1, r2, g2, b2)
    return (r1 - r2) ^ 2 + (g1 - g2) ^ 2 + (b1 - b2) ^ 2
end

local function hex_to_xterm(hex)
    local r, g, b = hex_to_rgb(hex)
    local min_dist = math.huge
    local closest_idx = 0
    for idx, rgb in pairs(xterm_palette) do
        local dist = rgb_distance(r, g, b, rgb[1], rgb[2], rgb[3])
        if dist < min_dist then
            min_dist = dist
            closest_idx = idx
        end
    end
    return closest_idx
end

function M.compile_ghostty()
    local template = [[# Flume Theme for Ghostty
background = %s
foreground = %s
selection-background = %s
selection-foreground = %s
cursor-color = %s
cursor-text = %s

palette = 0=%s
palette = 1=%s
palette = 2=%s
palette = 3=%s
palette = 4=%s
palette = 5=%s
palette = 6=%s
palette = 7=%s
palette = 8=%s
palette = 9=%s
palette = 10=%s
palette = 11=%s
palette = 12=%s
palette = 13=%s
palette = 14=%s
palette = 15=%s
]]
    local content = string.format(
        template,
        palette.bg,
        palette.fg,
        palette.black, -- selection-background
        palette.fg, -- selection-foreground
        palette.accent,
        palette.bg, -- cursor-text
        palette.black,
        palette.red,
        palette.green,
        palette.yellow,
        palette.blue,
        palette.magenta,
        palette.cyan,
        palette.white,
        palette.bright_black,
        palette.bright_red,
        palette.bright_green,
        palette.bright_yellow,
        palette.bright_blue,
        palette.bright_magenta,
        palette.bright_cyan,
        palette.bright_white
    )

    local path = "extras/ghostty/flume"
    local file = io.open(path, "w")
    if file then
        file:write(content)
        file:close()
    else
        error("Could not write to file: " .. path)
    end
end

function M.compile_tmux()
    local template = [[# Flume tmux color variables.

%%hidden thm_bg="%s"
%%hidden thm_fg="%s"
%%hidden thm_black="%s"
%%hidden thm_gray="%s"
%%hidden thm_lgray="%s"
%%hidden thm_accent="%s"
%%hidden thm_red="%s"
%%hidden thm_green="%s"
%%hidden thm_yellow="%s"
%%hidden thm_blue="%s"
%%hidden thm_pink="%s"
%%hidden thm_cyan="%s"
%%hidden thm_orange="%s"
]]
    local content = string.format(
        template,
        palette.bg,
        palette.fg,
        palette.black,
        palette.black, -- thm_gray
        palette.placeholder,
        palette.accent,
        palette.red,
        palette.green,
        palette.yellow,
        palette.blue,
        palette.magenta,
        palette.cyan,
        palette.bright_red -- thm_orange
    )

    local path = "extras/tmux/colors.conf"
    local file = io.open(path, "w")
    if file then
        file:write(content)
        file:close()
    else
        error("Could not write to file: " .. path)
    end
end

function M.compile_lsd()
    local template = [[# Flume colors for lsd.
# lsd 1.1.x uses crossterm color values; use xterm-256 approximations
# instead of #RRGGBB so the theme is actually applied.

name:
  file: %d            # syntax_primary (%s)
  dir: %d             # accent (%s)
  pipe: %d            # cyan (%s)
  symlink: %d         # cyan (%s)
  block-device: %d    # magenta (%s)
  char-device: %d     # magenta (%s)
  socket: %d          # magenta (%s)
  special: %d         # syntax_special (%s)

user: %d              # muted (%s)
group: %d             # placeholder/comment (%s)

permission:
  read: %d            # muted (%s)
  write: %d           # yellow (%s)
  exec: %d            # green (%s)
  exec-sticky: %d     # magenta (%s)
  no-access: %d       # placeholder/comment (%s)
  octal: %d           # bright_blue (%s)
  acl: %d             # cyan (%s)
  context: %d         # doc_comment (%s)

date:
  hour-old: %d        # syntax_primary (%s)
  day-old: %d         # muted (%s)
  older: %d           # placeholder/comment (%s)

size:
  none: %d            # placeholder/comment (%s)
  small: %d           # muted (%s)
  medium: %d          # cyan (%s)
  large: %d           # yellow (%s)

inode:
  valid: %d           # muted (%s)
  invalid: %d         # placeholder/comment (%s)

links:
  valid: %d           # muted (%s)
  invalid: %d         # placeholder/comment (%s)

tree-edge: %d         # border_variant (%s)

git-status:
  default: %d         # placeholder/comment (%s)
  unmodified: %d      # placeholder/comment (%s)
  ignored: %d         # placeholder/comment (%s)
  new-in-index: %d    # green (%s)
  new-in-workdir: %d  # green (%s)
  typechange: %d      # yellow (%s)
  deleted: %d         # red (%s)
  renamed: %d         # accent (%s)
  modified: %d        # yellow (%s)
  conflicted: %d      # bright_red (%s)
]]

    local content = string.format(
        template,
        hex_to_xterm(palette.syntax_primary),
        palette.syntax_primary,
        hex_to_xterm(palette.accent),
        palette.accent,
        hex_to_xterm(palette.cyan),
        palette.cyan,
        hex_to_xterm(palette.cyan),
        palette.cyan,
        hex_to_xterm(palette.magenta),
        palette.magenta,
        hex_to_xterm(palette.magenta),
        palette.magenta,
        hex_to_xterm(palette.magenta),
        palette.magenta,
        hex_to_xterm(palette.syntax_special),
        palette.syntax_special,

        hex_to_xterm(palette.muted),
        palette.muted,
        hex_to_xterm(palette.placeholder),
        palette.placeholder,

        hex_to_xterm(palette.muted),
        palette.muted,
        hex_to_xterm(palette.yellow),
        palette.yellow,
        hex_to_xterm(palette.green),
        palette.green,
        hex_to_xterm(palette.magenta),
        palette.magenta,
        hex_to_xterm(palette.placeholder),
        palette.placeholder,
        hex_to_xterm(palette.bright_blue),
        palette.bright_blue,
        hex_to_xterm(palette.cyan),
        palette.cyan,
        hex_to_xterm(palette.syntax_doc_comment),
        palette.syntax_doc_comment,

        hex_to_xterm(palette.syntax_primary),
        palette.syntax_primary,
        hex_to_xterm(palette.muted),
        palette.muted,
        hex_to_xterm(palette.placeholder),
        palette.placeholder,

        hex_to_xterm(palette.placeholder),
        palette.placeholder,
        hex_to_xterm(palette.muted),
        palette.muted,
        hex_to_xterm(palette.cyan),
        palette.cyan,
        hex_to_xterm(palette.yellow),
        palette.yellow,

        hex_to_xterm(palette.muted),
        palette.muted,
        hex_to_xterm(palette.placeholder),
        palette.placeholder,

        hex_to_xterm(palette.muted),
        palette.muted,
        hex_to_xterm(palette.placeholder),
        palette.placeholder,

        hex_to_xterm(palette.border_variant),
        palette.border_variant,

        hex_to_xterm(palette.placeholder),
        palette.placeholder,
        hex_to_xterm(palette.placeholder),
        palette.placeholder,
        hex_to_xterm(palette.placeholder),
        palette.placeholder,
        hex_to_xterm(palette.green),
        palette.green,
        hex_to_xterm(palette.green),
        palette.green,
        hex_to_xterm(palette.yellow),
        palette.yellow,
        hex_to_xterm(palette.red),
        palette.red,
        hex_to_xterm(palette.accent),
        palette.accent,
        hex_to_xterm(palette.yellow),
        palette.yellow,
        hex_to_xterm(palette.bright_red),
        palette.bright_red
    )

    local path = "extras/lsd/colors.yaml"
    local file = io.open(path, "w")
    if file then
        file:write(content)
        file:close()
    else
        error("Could not write to file: " .. path)
    end
end

function M.compile_all()
    -- Create extras directories if they don't exist
    os.execute("mkdir -p extras/ghostty extras/tmux extras/lsd")

    M.compile_ghostty()
    M.compile_tmux()
    M.compile_lsd()
    print("Flume extras successfully compiled!")
end

return M
