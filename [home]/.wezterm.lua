local wezterm = require 'wezterm'
return {
  window_decorations = "RESIZE",
  font = wezterm.font_with_fallback {
    'JetBrainsMono NFM',
    'FiraCode NFM'
  },
  color_scheme = "OneHalfDark",
  enable_tab_bar = false,
  window_background_opacity = 1,
  audible_bell = "Disabled",
  default_prog = {
    'powershell.exe', '-NoExit', '-Command',
    "&{Import-Module \"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\Common7\\Tools\\Microsoft.VisualStudio.DevShell.dll\"; Enter-VsDevShell 8977de2d -SkipAutomaticLocation -DevCmdArguments \"-arch=x64 -host_arch=x64\"; nu.exe; exit }"
  },
  -- default_domain = "ubuntu",
  keys = {
    {
      key = 'Backspace',
      mods = 'CTRL',
      action = wezterm.action.SendKey {
        key = 'Backspace',
        mods = 'META',
      }
    },
    {
      key = 'H',
      mods = 'CTRL',
      action = wezterm.action.ActivatePaneDirection "Left"
    },
    {
      key = 'J',
      mods = 'CTRL',
      action = wezterm.action.ActivatePaneDirection "Down"
    },
    {
      key = 'K',
      mods = 'CTRL',
      action = wezterm.action.ActivatePaneDirection "Up"
    },
    {
      key = 'L',
      mods = 'CTRL',
      action = wezterm.action.ActivatePaneDirection "Right"
    },
    {
      key = '<',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
    },
    {
      key = '>',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
    },
    {
      key = 'l',
      mods = 'ALT|SHIFT',
      action = wezterm.action.AdjustPaneSize { "Right", 1 },
    },
    {
      key = 'h',
      mods = 'ALT|SHIFT',
      action = wezterm.action.AdjustPaneSize { "Left", 1 },
    },
    {
      key = 'k',
      mods = 'ALT|SHIFT',
      action = wezterm.action.AdjustPaneSize { "Up", 1 },
    },
    {
      key = 'j',
      mods = 'ALT|SHIFT',
      action = wezterm.action.AdjustPaneSize { "Down", 1 },
    },
    {
      key = 'j',
      mods = 'CTRL',
      action = wezterm.action.SendKey {
        key = 'DownArrow'
      },
    },
    {
      key = 'k',
      mods = 'CTRL',
      action = wezterm.action.SendKey {
        key = 'UpArrow'
      },
    },
    {
      key = 'h',
      mods = 'CTRL',
      action = wezterm.action.SendKey {
        key = 'LeftArrow'
      },
    },
    {
      key = 'l',
      mods = 'CTRL',
      action = wezterm.action.SendKey {
        key = 'RightArrow'
      },
    },
    {
      key = 'p',
      mods = 'CTRL',
      action = wezterm.action.SendKey {
        key = 'l',
        mods = 'CTRL'
      },
    },
    {
      key = 'Z',
      mods = 'CTRL',
      action = wezterm.action.TogglePaneZoomState,
    }
  },
  unix_domains = {
    {
      name = 'unix',
    },
  },
  wsl_domains = {
    {
      -- The name of this specific domain.  Must be unique amonst all types
      -- of domain in the configuration file.
      name = 'ubuntu',

      -- The name of the distribution.  This identifies the WSL distribution.
      -- It must match a valid distribution from your `wsl -l -v` output in
      -- order for the domain to be useful.
      distribution = 'Ubuntu',

      -- The username to use when spawning commands in the distribution.
      -- If omitted, the default user for that distribution will be used.

      -- username = "hunter",

      -- The current working directory to use when spawning commands, if
      -- the SpawnCommand doesn't otherwise specify the directory.

      default_cwd = "~"

      -- The default command to run, if the SpawnCommand doesn't otherwise
      -- override it.  Note that you may prefer to use `chsh` to set the
      -- default shell for your user inside WSL to avoid needing to
      -- specify it here

      -- default_prog = { "bash" }
    },
  },
}
