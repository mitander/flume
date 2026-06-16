#!/bin/bash
# Query a color value from the Flume theme palette

KEY=$1
if [ -z "$KEY" ]; then
    echo "Usage: $0 <color-key>"
    exit 1
fi

# Locate theme file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE="$SCRIPT_DIR/../ghostty/flume"
[ -f "$FILE" ] || FILE=~/.config/ghostty/themes/flume

# Fallback default values
if [ ! -f "$FILE" ]; then
    case "$KEY" in
        background) echo "#232136" ;;
        foreground) echo "#e0def4" ;;
        palette_0) echo "#393552" ;;
        selection-background) echo "#393552" ;;
        syntax_comment) echo "#6e6a86" ;;
        *) echo "#e0def4" ;;
    esac
    exit 0
fi

# Parse key using a single-pass awk script
awk -F'=' -v key="$KEY" '
    function trim(str) {
        gsub(/^[ \t]+|[ \t]+$/, "", str)
        return str
    }
    {
        # Strip comments unless they match custom override assignments
        line = $0
        if (line ~ /^#[ \t]*[a-zA-Z_0-9-]+[ \t]*=/) {
            sub(/^#[ \t]*/, "", line)
        } else if (line ~ /^#/) {
            next
        }
        
        n = split(line, parts, "=")
        if (n >= 2) {
            k = trim(parts[1])
            
            # Match palette index (e.g., palette_4 matches palette = 4=#color)
            if (k == "palette" && key ~ /^palette_/) {
                split(key, key_parts, "_")
                idx = key_parts[2]
                
                curr_idx = parts[2]
                gsub(/[ \t]+/, "", curr_idx)
                
                if (curr_idx == idx) {
                    val = parts[3]
                    gsub(/[ \t\r]+/, "", val)
                    print val
                    exit
                }
            } else if (k == key) {
                val = parts[2]
                gsub(/[ \t\r]+/, "", val)
                print val
                exit
            }
        }
    }
' "$FILE"
