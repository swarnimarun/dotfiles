# font-picker

Switch the WezTerm font from a fuzzy selector menu. The switch is live (no
restart) and the choice is remembered across restarts.

## Install

Drop this directory at `~/.config/wezterm/font-picker/` and require it with
`require("font-picker")`.

WezTerm 20240203 does not discover local `~/.config/wezterm/plugins/*/`
directories (`wezterm.plugin.require` only accepts git URLs there), so a plain
`require` against the config dir's `package.path` is the portable way. The
`plugin.toml` is included for newer builds that do read it.

## Use

```lua
local font_picker = require("font-picker")

font_picker.setup({
  -- anything here shows up in the menu
  fonts = {
    { family = "Nordwand Mono", weight = "Medium" },
    { family = "Nordwand Mono", weight = "Regular" },
    { family = "JetBrains Mono", weight = "Regular" },
    { label = "Codicon only", family = "Codicon" },
  },
  -- optional: expand every family that has no explicit weight into these
  weights = { "Regular" },
  -- glyphs the chosen font lacks (nerd font icons, powerline, emoji)
  fallback = { "JetBrains Mono", "Symbols Nerd Font Mono" },
  -- default: ~/.config/wezterm/.font-picker.state
  state_file = "/some/other/path",
  -- title of the menu
  title = "Font",
})

config.font = font_picker.font_for("JetBrains Mono")
font_picker.apply_saved(config) -- honour the last pick

config.keys = {
  { key = "f", mods = "ALT|SHIFT", action = font_picker.picker() },
  { key = "f", mods = "ALT|CTRL", action = font_picker.cycle(1) },
  { key = "f", mods = "ALT|CTRL|SHIFT", action = font_picker.cycle(-1) },
}
```

## API

| function | description |
| --- | --- |
| `setup(opts)` | configure fonts, fallbacks, weights, state file, title |
| `apply_saved(config)` | set `config.font` to the remembered pick; call before `return config` |
| `picker()` | action: fuzzy menu that switches the font |
| `cycle(n)` | action: move `n` entries through the list (wraps) |
| `apply_label(label)` | switch to an entry by label without the menu |
| `font_for(label)` | the `wezterm.font_with_fallback` object for a label, or nil |
| `labels()` | the labels the menu will offer, in order |

The current font is marked with `●` in the menu. `apply_label`, `font_for` and
`labels()` are safe to call while the config is loading; applying a font there
writes the state file but only touches windows from the GUI thread.

## State file

One value per line: family, weight, then fallback families. Delete it to fall
back to the font configured in `wezterm.lua`.
