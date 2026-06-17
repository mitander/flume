#!/bin/bash

# Resolve path relative to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE="$SCRIPT_DIR/../ghostty/flume"
if [ ! -f "$FILE" ]; then
    FILE=~/.config/ghostty/themes/flume
fi

# Target file to write
TARGET_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux"
mkdir -p "$TARGET_DIR"
TARGET_FILE="$TARGET_DIR/flume-colors.conf"

# Generate colors.conf in a single pass using awk
awk -F'=' '
    function trim(str) {
        gsub(/^[ \t]+|[ \t]+$/, "", str)
        return str
    }

    {
        # Check if line is a comment or custom override
        is_override = 0
        line = $0
        if (line ~ /^#[ \t]*[a-zA-Z_0-9-]+[ \t]*=/) {
            is_override = 1
            sub(/^#[ \t]*/, "", line)
        } else if (line ~ /^#/) {
            next
        }

        # Split line by =
        n = split(line, parts, "=")
        if (n >= 2) {
            key = trim(parts[1])
            if (key == "palette") {
                idx = parts[2]
                color = parts[3]
                gsub(/[ \t]+/, "", idx)
                gsub(/[ \t\r]+/, "", color)
                palette[idx] = color
            } else {
                val = parts[2]
                gsub(/[ \t\r]+/, "", val)
                colors[key] = val
            }
        }
    }

    END {
        bg = colors["background"] ? colors["background"] : "#232136"
        fg = colors["foreground"] ? colors["foreground"] : "#e0def4"
        black = palette[0] ? palette[0] : "#393552"
        gray = colors["selection-background"] ? colors["selection-background"] : "#393552"
        lgray = colors["syntax_comment"] ? colors["syntax_comment"] : "#6e6a86"
        red = palette[1] ? palette[1] : "#eb6f92"
        green = palette[2] ? palette[2] : "#a3be8c"
        yellow = palette[3] ? palette[3] : "#f6c177"
        blue = palette[4] ? palette[4] : "#569fba"
        pink = palette[5] ? palette[5] : "#c4a7e7"
        cyan = palette[6] ? palette[6] : "#9ccfd8"
        orange = palette[9] ? palette[9] : "#f083a2"

        print "# Generated colors"
        print "thm_bg=\"" bg "\""
        print "thm_fg=\"" fg "\""
        print "thm_black=\"" black "\""
        print "thm_gray=\"" gray "\""
        print "thm_lgray=\"" lgray "\""
        print "thm_red=\"" red "\""
        print "thm_green=\"" green "\""
        print "thm_yellow=\"" yellow "\""
        print "thm_blue=\"" blue "\""
        print "thm_pink=\"" pink "\""
        print "thm_cyan=\"" cyan "\""
        print "thm_orange=\"" orange "\""
    }
' "$FILE" > "$TARGET_FILE"

# Append TMUX styles to colors.conf
cat <<'EOF' >> "$TARGET_FILE"

# Apply styles
set -g status "on"
set -g status-left-length "100"
set -g status-right-length "100"
set -g status-position bottom
set -g status-justify centre
set -g status-style bg=$thm_gray,fg=$thm_fg
set -g status-left " #[bold]#[fg=$thm_blue, bg=$thm_gray]#H #[bold]#[fg=$thm_green, bg=$thm_gray]#S "
set -g status-right "#[bold]#[fg=$thm_green, bg=$thm_gray]CPU#[default]#[bold]:#{cpu_percentage} #[bold]#[fg=$thm_blue, bg=$thm_gray]RAM#[default]#[bold]:#{ram_percentage} "
set -g window-status-separator " "
set -g window-status-current-format "#[bold]#[fg=$thm_fg, bg=$thm_gray]#I:#[fg=$thm_blue, bg=$thm_gray]#{b:pane_current_path}#[fg=$thm_fg, bg=$thm_gray]:#[fg=$thm_green, bg=$thm_gray]#W"
set -g window-status-format "#[bold]#[fg=$thm_lgray, bg=$thm_gray]#I:#{b:pane_current_path}:#W"
set -g pane-border-style fg=$thm_gray
set -g pane-active-border-style fg=$thm_lgray
set -g pane-border-indicators off
set -g pane-border-lines single
set -g pane-border-status off
set -g pane-border-format "#{?pane_active,#[fg=$thm_lgray]#{R:─,#{pane_width}}#[default],}"
set-hook -g after-split-window[99] 'if -F "#{>:#{window_panes},1}" "set -w pane-border-status top" "set -w pane-border-status off"'
set-hook -g after-kill-pane[99] 'if -F "#{>:#{window_panes},1}" "set -w pane-border-status top" "set -w pane-border-status off"'
set-hook -g pane-exited[99] 'if -F "#{>:#{window_panes},1}" "set -w pane-border-status top" "set -w pane-border-status off"'
set-hook -g window-layout-changed[99] 'if -F "#{>:#{window_panes},1}" "set -w pane-border-status top" "set -w pane-border-status off"'
run-shell -b 'tmux -S "#{socket_path}" list-windows -a -F "##{window_id} ##{window_panes}" | while read -r win panes; do if [ "$panes" -gt 1 ]; then tmux -S "#{socket_path}" set -w -t "$win" pane-border-status top; else tmux -S "#{socket_path}" set -w -t "$win" pane-border-status off; fi; done'
EOF

# Source the generated file in TMUX
tmux source-file "$TARGET_FILE"
