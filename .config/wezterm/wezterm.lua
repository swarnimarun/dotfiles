local wezterm = require("wezterm")

-- config fields
local config = {}

config.window_decorations = "RESIZE"
config.font_size = 12.0

-- Font switching: ALT+SHIFT+F opens a fuzzy font menu that switches the font
-- live (no restart) and remembers the pick in ~/.config/wezterm/.font-picker.state.
-- ALT+CTRL+F / ALT+CTRL+SHIFT+F cycle forwards/backwards through the list.
local font_picker = require("font-picker")
font_picker.setup({
    -- Everything listed here appears in the menu; add or remove freely.
    -- Weights: "Thin", "ExtraLight", "Light", "DemiLight", "Book", "Regular",
    --          "Medium", "DemiBold", "Bold", "ExtraBold", "Black", "ExtraBlack"
    fonts = {
        -- Nordwand has no nerd glyphs; icons come from the fallback list below.
        { family = "Nordwand Mono", weight = "Regular" },
        { family = "Nordwand Mono", weight = "Medium" },
        { family = "Nordwand Mono", weight = "Light" },
        -- balanced / modern, with texture healing
        { family = "JetBrainsMono Nerd Font Mono", weight = "Regular" },
        { family = "JetBrainsMono Nerd Font Mono", weight = "Medium" },
        { family = "Monaspace Neon NF", weight = "Regular" },
        { family = "Monaspace Neon NF", weight = "Medium" },
        { family = "Monaspace Argon NF", weight = "Regular" },
        { family = "Monaspace Xenon NF", weight = "Regular" },
        { family = "Monaspace Radon NF", weight = "Regular" },
        { family = "Monaspace Krypton NF", weight = "Regular" },
        -- clarity first, no operator-reshaping ligatures
        { family = "0xProto Nerd Font Mono", weight = "Regular" },
        { family = "AtkynsonMono Nerd Font Mono", weight = "Regular" }, -- Atkinson Hyperlegible Mono
        -- compact: more code per pane
        { family = "IosevkaTerm Nerd Font Mono", weight = "Regular" },
        { family = "IosevkaTerm Nerd Font Mono", weight = "Medium" },
        -- the rest
        { family = "Maple Mono NF", weight = "Regular" },
        { family = "Maple Mono NF", weight = "Medium" },
        { family = "GeistMono Nerd Font Mono", weight = "Regular" },
        { family = "CaskaydiaMono Nerd Font Mono", weight = "Regular" },
        { family = "CaskaydiaCove Nerd Font Mono", weight = "Regular" },
        { family = "FiraCode Nerd Font Mono", weight = "Regular" },
        { family = "FiraCode Nerd Font Mono", weight = "Medium" },
        -- plain mono, no nerd variant installed
        { family = "JetBrains Mono", weight = "Regular" },
    },
    -- Glyphs the chosen font is missing (nerd font icons, emoji) come from here.
    fallback = { "JetBrains Mono", "Symbols Nerd Font Mono" },
})

config.font = font_picker.font_for("Nordwand Mono Medium")
    or wezterm.font_with_fallback({ "JetBrains Mono", "Symbols Nerd Font Mono" })
-- Honour whatever was last picked from the menu.
font_picker.apply_saved(config)

-- harfbuzz_features is required for setting texture healing with Monaspace
-- !==, ===, ==, =/=, </, </>, |>, <|, .=, .-, >=
config.harfbuzz_features = {
    "ss01",
    -- "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08", "calt", "dlig"
}

config.color_scheme = 'Dark+'
config.audible_bell = "Disabled"
-- on windows use nu.exe
config.default_prog = { "/opt/homebrew/bin/fish" }

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

local sessionizer = wezterm.plugin.require "https://github.com/mikkasendke/sessionizer.wezterm"
local my_schema = {
  sessionizer.DefaultWorkspace {},
  sessionizer.AllActiveWorkspaces {},
  sessionizer.FdSearch {
     wezterm.home_dir .. "/repos/github.com",
     fd_path = "/Users/swarnim/.cargo/bin/fd",
  },
  wezterm.home_dir .. "/repos",
  wezterm.home_dir .. "/.config/wezterm",
  wezterm.home_dir .. "/.config/helix",
  wezterm.home_dir .. "/.config/fish",
  wezterm.home_dir .. "/.config/jj",
  wezterm.home_dir .. "/.config/gitui",
  -- Make paths more readable by replacing home directory with ~
  processing = sessionizer.for_each_entry(function(entry)
    entry.label = entry.label:gsub(wezterm.home_dir .. "/repos/github.com/swarnimarun", "<swarnimarun>")
    entry.label = entry.label:gsub(wezterm.home_dir .. "/repos/github.com/prassoai", "<pr>")
    entry.label = entry.label:gsub(wezterm.home_dir .. "/repos/github.com/aftershootco", "<af>")
    entry.label = entry.label:gsub(wezterm.home_dir, "~")
  end)
}

config.keys = {
    {
        key = "s",
        mods = "ALT",
        action = sessionizer.show(my_schema)
    },
    -- fuzzy search & select workspace
    {
        key = "i",
        mods = "CTRL|SHIFT",
        action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
    },
    -- fuzzy search & select tabs
    {
        key = "o",
        mods = "CTRL|SHIFT",
        action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|TABS" }),
    },
    -- fuzzy search & select tabs
    {
        key = "H",
        mods = "CTRL",
        action = wezterm.action.ActivatePaneDirection("Left"),
    },
    {
        key = "J",
        mods = "CTRL",
        action = wezterm.action.ActivatePaneDirection("Down"),
    },
    {
        key = "K",
        mods = "CTRL",
        action = wezterm.action.ActivatePaneDirection("Up"),
    },
    {
        key = "L",
        mods = "CTRL",
        action = wezterm.action.ActivatePaneDirection("Right"),
    },
    {
        key = "<",
        mods = "CTRL|SHIFT",
        action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
        key = ">",
        mods = "CTRL|SHIFT",
        action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    {
        key = "l",
        mods = "ALT|SHIFT",
        action = wezterm.action.AdjustPaneSize({ "Right", 1 }),
    },
    {
        key = "h",
        mods = "ALT|SHIFT",
        action = wezterm.action.AdjustPaneSize({ "Left", 1 }),
    },
    {
        key = "k",
        mods = "ALT|SHIFT",
        action = wezterm.action.AdjustPaneSize({ "Up", 1 }),
    },
    {
        key = "j",
        mods = "ALT|SHIFT",
        action = wezterm.action.AdjustPaneSize({ "Down", 1 }),
    },
    {
        key = "j",
        mods = "ALT",
        action = wezterm.action.SendKey({
            key = "DownArrow",
        }),
    },
    {
        key = "k",
        mods = "ALT",
        action = wezterm.action.SendKey({
            key = "UpArrow",
        }),
    },
    {
        key = "h",
        mods = "ALT",
        action = wezterm.action.SendKey({
            key = "LeftArrow",
        }),
    },
    {
        key = "l",
        mods = "ALT",
        action = wezterm.action.SendKey({
            key = "RightArrow",
        }),
    },
    {
        key = "Z",
        mods = "CTRL",
        action = wezterm.action.TogglePaneZoomState,
    },
    -- font switching
    {
        key = "f",
        mods = "ALT|SHIFT",
        action = font_picker.picker(),
    },
    {
        key = "f",
        mods = "ALT|CTRL",
        action = font_picker.cycle(1),
    },
    {
        key = "f",
        mods = "ALT|CTRL|SHIFT",
        action = font_picker.cycle(-1),
    },
}

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = {
    icons_enabled = true,
    theme = 'GruvboxDark',
    tabs_enabled = true,
    theme_overrides = {},
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
  },
  sections = {
    tabline_a = { 'mode' },
    tabline_b = { 'workspace' },
    tabline_c = { '' },
    tab_active = {
        { 'process' },
    },
    tab_inactive = {
        { 'process' }
    },
    tabline_x = { 'ram', 'cpu' },
    tabline_y = { '' },
    tabline_z = { 'datetime', 'battery' },
  },
  extensions = {},
})
tabline.apply_to_config(config)
config.tab_bar_at_bottom = true

return config

