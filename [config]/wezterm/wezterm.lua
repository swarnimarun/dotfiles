local wezterm = require("wezterm")
local sessionizer = require("sessionizer")

-- config fields
local config = {
    -- range =  0.0 .. 1.0
    -- window_background_opacity = 1.0,
    -- text_background_opacity = 0.9,
    -- win32_system_backdrop = "Acrylic",
    -- win32_system_backdrop = 'Tabbed',
}

config.window_decorations = "RESIZE"
-- default is 12.0
config.font_size = 12.0
config.font_dirs = { "C:\\Windows\\Fonts" }
config.font = wezterm.font_with_fallback({
    -- possible weights :: "Thin", "ExtraLight", "Light", "DemiLight", "Book", "Regular", "Medium", "DemiBold", "Bold", "ExtraBold", "Black", "ExtraBlack",
    -- { family = "MonaspiceNe NF", weight = "Medium" },
    { family = "JetBrainsMono NFM", weight = "Medium" },
})

-- harfbuzz_features is required for setting texture healing with Monaspace
-- !==, ===, ==, =/=, </, </>, |>, <|, .=, .-, >=
config.harfbuzz_features = {
    "ss01", "ss02", "ss03",
    "ss04", "ss05", "ss06",
    "ss07", "ss08", "calt", "dlig"
}

config.color_scheme = 'Dark+'
config.enable_tab_bar = false
config.audible_bell = "Disabled"

config.default_prog = { "nu.exe" }

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  -- {
  --   event = { Up = { streak = 1, button = "Left" } },
  --   mods = "NONE",
  --   action = wezterm.action.Nop,
  -- },
}
-- config.mouse_bindings = {
--     {
--         event = { Up = { streak = 1, button = "Left" } },
--         mods = "NONE",
--         action = wezterm.action.Nop,
--     },
--     -- Bind 'Up' event of CTRL-Click to open hyperlinks
--     {
--         event = { Up = { streak = 1, button = "Left" } },
--         mods = "CTRL",
--         action = wezterm.action.OpenLinkAtMouseCursor,
--     },
--     -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
--     {
--         event = { Down = { streak = 1, button = "Left" } },
--         mods = "CTRL",
--         action = wezterm.action.Nop,
--     },
-- }

config.keys = {
    -- fuzzy search & select workspace
    { key = "f", mods = "CTRL", action = wezterm.action_callback(sessionizer.start) },
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

return config
