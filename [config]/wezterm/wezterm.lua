local wezterm = require("wezterm")

-- config fields
local config = {}

config.window_decorations = "RESIZE"
config.font_size = 12.0
config.font = wezterm.font_with_fallback({
    -- possible weights :: "Thin", "ExtraLight", "Light", "DemiLight", "Book", "Regular", "Medium", "DemiBold", "Bold", "ExtraBold", "Black", "ExtraBlack",
    -- { family = "MonaspiceNe NF", weight = "Medium" },
    -- { family = 'CaskaydiaCove Nerd Font Mono', weight = 'Book' },
    "JetBrains Mono",
    -- { family = 'Geist Mono', weight = 'Bold' },
    -- "FiraCode Nerd Font Mono",
    -- 'DengXian',
})

-- harfbuzz_features is required for setting texture healing with Monaspace
-- !==, ===, ==, =/=, </, </>, |>, <|, .=, .-, >=
config.harfbuzz_features = {
    "ss01",
    -- "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08", "calt", "dlig"
}

config.color_scheme = 'Dark+'
config.audible_bell = "Disabled"
-- on windows use nu.exe
config.default_prog = { "fish" }

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

config.keys = {
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
}

local sessionizer = wezterm.plugin.require "https://github.com/mikkasendke/sessionizer.wezterm"
sessionizer.config= {
    paths = {
        "/Users/swarnimarun/repos/gitlab.com",
        "/Users/swarnimarun/repos/sourcehut.com",
        "/Users/swarnimarun/repos/github.com",
        "/Users/swarnimarun/repos/github.com/steincodes",
        "/Users/swarnimarun/repos/github.com/swarnimarun",
    },
    command_options = {
        fd_path = "/Users/swarnimarun/.cargo/bin/fd",
    }
}
sessionizer.apply_to_config(config)

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

