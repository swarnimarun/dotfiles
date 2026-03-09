local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Centralized settings keep the rest of the file easy to scan and edit.
-- Change values here instead of hunting through the config body.
local settings = {
    font_family = "JetBrains Mono",
    font_size = {
        windows = 10.0,
        macos = 12.0,
        linux = 10.0,
        fallback = 10.0,
    },
    color_scheme = "Dark+",
    preferred_wsl_distributions = {
        "NixOS",
        "Ubuntu-24.04",
        "Ubuntu-22.04",
        "Ubuntu",
        "Debian",
    },
    workspace_roots = {
        wezterm.home_dir .. "/repos/github.com/swarnimarun",
        wezterm.home_dir .. "/.config/wezterm",
        wezterm.home_dir .. "/.config/helix",
    },
    repo_search_root = wezterm.home_dir .. "/repos/github.com",
    debug = {
        -- These are controlled by environment variables so you can turn them
        -- on without editing the config.
        key_events = false,
        unknown_escape_sequences = false,
        automatically_reload_config = true,
        startup_logging = false,
    },
}

local function env_bool(name, default)
    local value = os.getenv(name)
    if value == nil or value == "" then
        return default
    end

    value = value:lower()
    return value == "1" or value == "true" or value == "yes" or value == "on"
end

settings.debug.key_events = env_bool("WEZTERM_DEBUG_KEY_EVENTS", settings.debug.key_events)
settings.debug.unknown_escape_sequences = env_bool(
    "WEZTERM_LOG_UNKNOWN_ESCAPES",
    settings.debug.unknown_escape_sequences
)
settings.debug.automatically_reload_config = env_bool(
    "WEZTERM_AUTO_RELOAD_CONFIG",
    settings.debug.automatically_reload_config
)
settings.debug.startup_logging = env_bool("WEZTERM_LOG_STARTUP", settings.debug.startup_logging)

local target_triple = wezterm.target_triple
local is_windows = target_triple:find("windows", 1, true) ~= nil
local is_macos = target_triple:find("apple-darwin", 1, true) ~= nil

local function has_domain(domains, name)
    for _, domain in ipairs(domains or {}) do
        if domain.name == name then
            return true
        end
    end
    return false
end

local function first_available_wsl_domain(domains, preferred_distributions)
    for _, distribution in ipairs(preferred_distributions) do
        local candidate = "WSL:" .. distribution
        if has_domain(domains, candidate) then
            return candidate
        end
    end

    return nil
end

local function platform_font_size()
    if is_windows then
        return settings.font_size.windows
    end

    if is_macos then
        return settings.font_size.macos
    end

    return settings.font_size.linux or settings.font_size.fallback
end

local function configure_platform_defaults()
    -- Window decorations stay minimal so the terminal feels native on each OS.
    config.window_decorations = "RESIZE"
    config.font_size = platform_font_size()
    config.font = wezterm.font_with_fallback({
        settings.font_family,
    })
    config.color_scheme = settings.color_scheme
    config.audible_bell = "Disabled"

    -- These features are only obvious if you already know the Monaspace/ligature
    -- setup. Keeping them together makes it easier to swap the font later.
    config.harfbuzz_features = {
        "ss01",
        "ss02",
        "ss03",
        "ss04",
        "ss05",
        "ss06",
        "ss07",
        "ss08",
        "calt",
        "dlig",
    }

    -- We keep the stock SSH domains so the launcher can discover ~/.ssh/config
    -- hosts automatically. This is the least surprising default.
    config.ssh_domains = wezterm.default_ssh_domains()

    -- A generic Unix domain gives the launcher an explicit local mux target on
    -- systems where you want to connect manually rather than always starting local.
    config.unix_domains = {
        {
            name = "unix",
        },
    }

    config.debug_key_events = settings.debug.key_events
    config.log_unknown_escape_sequences = settings.debug.unknown_escape_sequences
    config.automatically_reload_config = settings.debug.automatically_reload_config

    if is_windows then
        -- On Windows, WSL is usually the primary shell environment.
        config.wsl_domains = wezterm.default_wsl_domains()
        config.default_domain = first_available_wsl_domain(config.wsl_domains, settings.preferred_wsl_distributions)
            or "local"
    else
        -- On Linux and macOS, local is the safest default.
        config.default_domain = "local"
    end
end

configure_platform_defaults()

if settings.debug.startup_logging then
    wezterm.log_info("wezterm config file:", wezterm.config_file)
    wezterm.log_info("wezterm target triple:", target_triple)
    wezterm.log_info("wezterm default domain:", config.default_domain)
    wezterm.log_info("wezterm debug key events:", settings.debug.key_events)
    wezterm.log_info("wezterm unknown escape logging:", settings.debug.unknown_escape_sequences)
end

local function update_plugins_and_reload(window, pane)
    -- Plugin updates do not reload config automatically, so do both here.
    wezterm.plugin.update_all()
    wezterm.log_info("wezterm plugins updated; reloading config")
    wezterm.reload_configuration()
end

config.mouse_bindings = {
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "NONE",
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
}

local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
local history = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-history")

local workspace_roots = settings.workspace_roots
local schema = {
    options = { callback = history.Wrapper(sessionizer.DefaultCallback) },
    sessionizer.DefaultWorkspace {},
    history.MostRecentWorkspace {},
    sessionizer.FdSearch(settings.repo_search_root),
    processing = sessionizer.for_each_entry(function(entry)
        -- Show paths relative to $HOME to keep the picker readable.
        entry.label = entry.label:gsub(wezterm.home_dir, "~")
    end),
}

for _, root in ipairs(workspace_roots) do
    table.insert(schema, root)
end

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
    options = {
        icons_enabled = true,
        theme = "GruvboxDark",
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
        tabline_a = { "mode" },
        tabline_b = { "workspace" },
        tabline_c = { "" },
        tab_active = {
            { "process" },
        },
        tab_inactive = {
            { "process" },
        },
        tabline_x = { "ram", "cpu" },
        tabline_y = { "" },
        tabline_z = { "datetime", "battery" },
    },
    extensions = {},
})
tabline.apply_to_config(config)

config.tab_bar_at_bottom = true

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
    {
      key = 'l',
      mods = 'LEADER',
      action = wezterm.action.ShowLauncherArgs {
        flags = 'FUZZY|DOMAINS',
        title = 'Switch/attach domain',
      },
    },
    { key = "Q", mods = "CTRL|SHIFT", action = wezterm.action.ActivateCopyMode },
    {
        key = "m",
        mods = "ALT",
        action = history.switch_to_most_recent_workspace,
    },
    {
        key = "s",
        mods = "ALT",
        action = sessionizer.show(schema),
    },
    {
        key = "O",
        mods = "CTRL|SHIFT",
        action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|TABS" }),
    },
    {
        key = "L",
        mods = "CTRL|SHIFT",
        action = wezterm.action.ShowDebugOverlay,
    },
    {
        key = "R",
        mods = "CTRL|SHIFT",
        action = wezterm.action.ReloadConfiguration,
    },
    {
        key = "P",
        mods = "CTRL|SHIFT",
        action = wezterm.action_callback(update_plugins_and_reload),
    },
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
        action = wezterm.action.SendKey({ key = "DownArrow" }),
    },
    {
        key = "k",
        mods = "ALT",
        action = wezterm.action.SendKey({ key = "UpArrow" }),
    },
    {
        key = "h",
        mods = "ALT",
        action = wezterm.action.SendKey({ key = "LeftArrow" }),
    },
    {
        key = "l",
        mods = "ALT",
        action = wezterm.action.SendKey({ key = "RightArrow" }),
    },
    {
        key = "Z",
        mods = "CTRL",
        action = wezterm.action.TogglePaneZoomState,
    },
}

return config
