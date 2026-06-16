local M = {}

M.colors = {
    border = "#56526e",
    border_variant = "#44415a",
    border_focused = "#569fba",
    surface = "#2a273f",
    surface_alt = "#393552",
    element = "#2a273f",
    element_hover = "#393552",
    element_active = "#44415a",
    bg = "#232136",
    terminal_bg = "#232136",
    fg = "#e0def4",
    text = "#e0def4",
    muted = "#908caa",
    placeholder = "#6e6a86",
    accent = "#569fba",
    active_line = "#2a273f",
    line_number = "#6e6a86",
    active_line_number = "#e0def4",
    indent_guide = "#393552",

    black = "#393552",
    bright_black = "#47407d",
    dim_black = "#2a273f",
    red = "#eb6f92",
    bright_red = "#f083a2",
    dim_red = "#a84a62",
    green = "#a3be8c",
    bright_green = "#b1d196",
    dim_green = "#71885f",
    yellow = "#f6c177",
    bright_yellow = "#f9cb8c",
    dim_yellow = "#b88752",
    blue = "#569fba",
    bright_blue = "#65b1cd",
    dim_blue = "#3c7288",
    magenta = "#c4a7e7",
    bright_magenta = "#ccb1ed",
    dim_magenta = "#8c74aa",
    cyan = "#9ccfd8",
    bright_cyan = "#a6dae3",
    dim_cyan = "#6f969e",
    white = "#e0def4",
    bright_white = "#e2e0f7",
    dim_white = "#908caa",

    syntax_attribute = "#74ade8",
    syntax_boolean = "#eb98c3",
    syntax_comment = "#6e6a86",
    syntax_doc_comment = "#878e98",
    syntax_constant = "#dfc184",
    syntax_function = "#73ade9",
    syntax_type = "#65b1cd",
    syntax_keyword = "#c4a7e7",
    syntax_primary = "#d8d5ea",
    syntax_property = "#e07a84",
    syntax_punctuation = "#d8d5ea",
    syntax_punctuation_bracket = "#d8d5ea",
    syntax_punctuation_special = "#b1574b",
    syntax_string = "#a3be8c",
    syntax_special = "#eb98c3",
    predictive = "#5a6a87",

    diff_add_bg = "#2f3d2d",
    diff_change_bg = "#2d3a45",
    diff_delete_bg = "#402834",
    hint = "#9ccfd8",
    hint_bg = "#2d3a45",
    warn_bg = "#493b2b",
}

local function load_ghostty_colors()
    local paths = {
        vim.fn.expand("~/.config/ghostty/themes/flume"),
        vim.fn.expand("~/dotfiles/ghostty/.config/ghostty/themes/flume"),
    }
    local f
    for _, path in ipairs(paths) do
        f = io.open(path, "r")
        if f then
            break
        end
    end
    if not f then
        return
    end

    local ghostty = {}
    for line in f:lines() do
        local clean_line = line:match("^%s*(.-)%s*$")
        if clean_line and clean_line ~= "" then
            local _, key, val = clean_line:match("^(#?)%s*([%w%-_]+)%s*=%s*(#[%da-fA-F]+)$")
            if not key then
                local _, pal_val = clean_line:match("^(#?)%s*palette%s*=%s*(.+)$")
                if pal_val then
                    local idx, color = pal_val:match("^(%d+)%s*=%s*(#[%da-fA-F]+)$")
                    if idx and color then
                        ghostty["color_" .. idx] = color
                    end
                end
            else
                ghostty[key] = val
            end
        end
    end
    f:close()

    local c = M.colors
    if ghostty.background then
        c.bg = ghostty.background
        c.terminal_bg = ghostty.background
        c.element = ghostty.background
    end
    if ghostty.foreground then
        c.fg = ghostty.foreground
        c.text = ghostty.foreground
        c.syntax_primary = ghostty.foreground
    end
    if ghostty["selection-background"] then
        c.surface_alt = ghostty["selection-background"]
        c.active_line = ghostty["selection-background"]
        c.indent_guide = ghostty["selection-background"]
    end

    local map = {
        color_0 = "black",
        color_1 = "red",
        color_2 = "green",
        color_3 = "yellow",
        color_4 = "blue",
        color_5 = "magenta",
        color_6 = "cyan",
        color_7 = "white",
        color_8 = "bright_black",
        color_9 = "bright_red",
        color_10 = "bright_green",
        color_11 = "bright_yellow",
        color_12 = "bright_blue",
        color_13 = "bright_magenta",
        color_14 = "bright_cyan",
        color_15 = "bright_white",
    }
    for k, v in pairs(map) do
        if ghostty[k] then
            c[v] = ghostty[k]
        end
    end

    for k, v in pairs(ghostty) do
        if c[k] ~= nil then
            c[k] = v
        end
    end
end

local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

function M.setup()
    load_ghostty_colors()
    local c = M.colors
    vim.o.background = "dark"
    vim.g.colors_name = "flume"

    hi("Normal", { fg = c.syntax_primary, bg = c.bg })
    hi("NormalNC", { fg = c.syntax_primary, bg = c.bg })
    hi("NormalFloat", { fg = c.fg, bg = c.surface })
    hi("FloatBorder", { fg = c.border, bg = c.bg })
    hi("FloatTitle", { fg = c.text, bg = c.surface, bold = true })
    hi("WinSeparator", { fg = c.border_variant, bg = c.bg })
    hi("SignColumn", { bg = c.bg })
    hi("FoldColumn", { fg = c.placeholder, bg = c.bg })
    hi("Folded", { fg = c.muted, bg = c.surface })
    hi("EndOfBuffer", { fg = c.bg, bg = c.bg })
    hi("NonText", { fg = c.line_number })
    hi("Whitespace", { fg = c.line_number })
    hi("IblIndent", { fg = c.indent_guide })
    hi("IblWhitespace", { fg = c.indent_guide })
    hi("ColorColumn", { bg = c.surface })
    hi("CursorLine", { bg = c.active_line })
    hi("CursorLineNr", { fg = c.active_line_number, bg = c.active_line, bold = true })
    hi("LineNr", { fg = c.line_number, bg = c.bg })
    hi("Visual", { bg = c.element_active })
    hi("Search", { fg = c.text, bg = c.dim_blue })
    hi("IncSearch", { fg = c.terminal_bg, bg = c.yellow })
    hi("CurSearch", { fg = c.terminal_bg, bg = c.yellow })
    hi("MatchParen", { fg = c.text, bg = c.element_active, bold = true })
    hi("Directory", { fg = c.accent })
    hi("Title", { fg = c.syntax_property })

    hi("StatusLine", { fg = c.text, bg = c.surface_alt })
    hi("StatusLineNC", { fg = c.muted, bg = c.surface })
    hi("TabLine", { fg = c.muted, bg = c.surface })
    hi("TabLineSel", { fg = c.text, bg = c.bg, bold = true })
    hi("TabLineFill", { bg = c.surface })

    hi("Pmenu", { fg = c.fg, bg = c.surface })
    hi("PmenuSel", { fg = c.text, bg = c.element_active })
    hi("PmenuSbar", { bg = c.surface })
    hi("PmenuThumb", { bg = c.bright_black })
    hi("WildMenu", { fg = c.text, bg = c.element_active })

    hi("Question", { fg = c.green })
    hi("MoreMsg", { fg = c.green })
    hi("WarningMsg", { fg = c.yellow })
    hi("ErrorMsg", { fg = c.red })
    hi("ModeMsg", { fg = c.text })

    hi("DiffAdd", { bg = c.diff_add_bg })
    hi("DiffChange", { bg = c.diff_change_bg })
    hi("DiffDelete", { fg = c.red, bg = c.diff_delete_bg })
    hi("DiffText", { bg = c.dim_blue })
    hi("Added", { fg = c.green })
    hi("Changed", { fg = c.yellow })
    hi("Removed", { fg = c.red })

    hi("DiagnosticError", { fg = c.red })
    hi("DiagnosticWarn", { fg = c.yellow })
    hi("DiagnosticInfo", { fg = c.accent })
    hi("DiagnosticHint", { fg = c.hint })
    hi("DiagnosticOk", { fg = c.green })
    hi("DiagnosticVirtualTextError", { fg = c.red, bg = c.diff_delete_bg })
    hi("DiagnosticVirtualTextWarn", { fg = c.yellow, bg = c.warn_bg })
    hi("DiagnosticVirtualTextInfo", { fg = c.accent, bg = c.hint_bg })
    hi("DiagnosticVirtualTextHint", { fg = c.hint, bg = c.hint_bg })
    hi("DiagnosticUnderlineError", { sp = c.red, undercurl = true })
    hi("DiagnosticUnderlineWarn", { sp = c.yellow, undercurl = true })
    hi("DiagnosticUnderlineInfo", { sp = c.accent, undercurl = true })
    hi("DiagnosticUnderlineHint", { sp = c.hint, undercurl = true })

    hi("Comment", { fg = c.syntax_comment })
    hi("Constant", { fg = c.syntax_constant })
    hi("String", { fg = c.syntax_string })
    hi("Character", { fg = c.syntax_string })
    hi("Number", { fg = c.syntax_boolean })
    hi("Boolean", { fg = c.syntax_boolean })
    hi("Float", { fg = c.syntax_boolean })
    hi("Identifier", { fg = c.syntax_primary })
    hi("Function", { fg = c.syntax_function })
    hi("Statement", { fg = c.syntax_keyword })
    hi("Conditional", { fg = c.syntax_keyword })
    hi("Repeat", { fg = c.syntax_keyword })
    hi("Label", { fg = c.accent })
    hi("Operator", { fg = c.syntax_type })
    hi("Keyword", { fg = c.syntax_keyword })
    hi("Exception", { fg = c.syntax_keyword })
    hi("PreProc", { fg = c.syntax_keyword })
    hi("Include", { fg = c.syntax_keyword })
    hi("Define", { fg = c.syntax_keyword })
    hi("Macro", { fg = c.syntax_keyword })
    hi("PreCondit", { fg = c.syntax_keyword })
    hi("Type", { fg = c.syntax_type })
    hi("StorageClass", { fg = c.syntax_keyword })
    hi("Structure", { fg = c.syntax_type })
    hi("Typedef", { fg = c.syntax_type })
    hi("Special", { fg = c.syntax_special })
    hi("SpecialChar", { fg = c.syntax_special })
    hi("Tag", { fg = c.accent })
    hi("Delimiter", { fg = c.syntax_punctuation })
    hi("SpecialComment", { fg = c.syntax_doc_comment })
    hi("Debug", { fg = c.red })
    hi("Underlined", { fg = c.accent, underline = true })
    hi("Ignore", { fg = c.placeholder })
    hi("Error", { fg = c.red })
    hi("Todo", { fg = c.yellow, bg = "NONE", bold = true })

    hi("@attribute", { fg = c.syntax_attribute })
    hi("@boolean", { fg = c.syntax_boolean })
    hi("@character", { fg = c.syntax_string })
    hi("@comment", { fg = c.syntax_comment })
    hi("@comment.documentation", { fg = c.syntax_doc_comment })
    hi("@constant", { fg = c.syntax_constant })
    hi("@constant.builtin", { fg = c.syntax_boolean })
    hi("@constructor", { fg = c.syntax_function })
    hi("@function", { fg = c.syntax_function })
    hi("@function.builtin", { fg = c.syntax_function })
    hi("@function.call", { fg = c.syntax_function })
    hi("@function.macro", { fg = c.syntax_function })
    hi("@keyword", { fg = c.syntax_keyword })
    hi("@keyword.conditional", { fg = c.syntax_keyword })
    hi("@keyword.function", { fg = c.syntax_keyword })
    hi("@keyword.operator", { fg = c.syntax_keyword })
    hi("@keyword.repeat", { fg = c.syntax_keyword })
    hi("@keyword.return", { fg = c.syntax_keyword })
    hi("@label", { fg = c.accent })
    hi("@module", { fg = c.syntax_primary })
    hi("@namespace", { fg = c.syntax_primary })
    hi("@number", { fg = c.syntax_boolean })
    hi("@number.float", { fg = c.syntax_boolean })
    hi("@operator", { fg = c.syntax_type })
    hi("@property", { fg = c.syntax_property })
    hi("@punctuation.bracket", { fg = c.syntax_punctuation_bracket })
    hi("@punctuation.delimiter", { fg = c.syntax_punctuation_bracket })
    hi("@punctuation.special", { fg = c.syntax_punctuation_special })
    hi("@string", { fg = c.syntax_string })
    hi("@string.documentation", { fg = c.syntax_string })
    hi("@string.escape", { fg = c.syntax_doc_comment })
    hi("@string.regexp", { fg = c.syntax_boolean })
    hi("@string.special", { fg = c.syntax_boolean })
    hi("@tag", { fg = c.accent })
    hi("@tag.attribute", { fg = c.syntax_attribute })
    hi("@tag.delimiter", { fg = c.syntax_property })
    hi("@text.literal", { fg = c.syntax_string })
    hi("@type", { fg = c.syntax_type })
    hi("@type.builtin", { fg = c.syntax_type })
    hi("@variable", { fg = c.syntax_primary })
    hi("@variable.builtin", { fg = c.syntax_boolean })
    hi("@variable.member", { fg = c.syntax_property })
    hi("@markup.heading", { fg = c.syntax_property, bold = true })
    hi("@markup.italic", { italic = true })
    hi("@markup.link", { fg = c.syntax_function, italic = true })
    hi("@markup.link.url", { fg = c.syntax_type, underline = true })
    hi("@markup.list", { fg = c.syntax_property })
    hi("@markup.raw", { fg = c.syntax_string })

    hi("GitSignsAdd", { fg = c.green, bg = c.bg })
    hi("GitSignsChange", { fg = c.yellow, bg = c.bg })
    hi("GitSignsDelete", { fg = c.red, bg = c.bg })
    hi("OilDir", { fg = c.accent })
    hi("OilFile", { fg = c.fg })
    hi("OilHidden", { fg = c.placeholder })
    hi("OilLink", { fg = c.cyan })
    hi("OilStatusLine", { fg = c.fg, bg = c.surface_alt, bold = true })

    local terminal_colors = {
        c.black,
        c.red,
        c.green,
        c.yellow,
        c.blue,
        c.magenta,
        c.cyan,
        c.white,
        c.bright_black,
        c.bright_red,
        c.bright_green,
        c.bright_yellow,
        c.bright_blue,
        c.bright_magenta,
        c.bright_cyan,
        c.bright_white,
    }

    for i, color in ipairs(terminal_colors) do
        vim.g["terminal_color_" .. (i - 1)] = color
    end

    vim.api.nvim_create_user_command("FlumeReload", function()
        vim.cmd("colorscheme flume")
        vim.notify("Flume colorscheme reloaded from Ghostty config!", vim.log.levels.INFO)
    end, {})
end

return M
