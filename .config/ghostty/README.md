# Ghostty

This directory mirrors the parts of `~/.config/wezterm/wezterm.lua` that Ghostty
can express directly.

## Ported settings

- Theme: `Dark+`
- Font: `JetBrains Mono`, size `12`
- Shell: `fish`
- Shell integration: prompt/cursor/title/path features enabled, SSH features
  disabled to match the WezTerm setup
- Window padding: `6 x 5`
- Cursor: block
- Mouse hide while typing: disabled
- Keybinds for:
  - reload/open config
  - copy/paste
  - search
  - select all
  - tabs and split windows
  - split navigation with `Ctrl+Shift+H/J/K/L`
  - split resize with `Alt+Shift+H/J/K/L`
  - fullscreen and split zoom
  - tab switching and tab overview

## Not ported

These WezTerm features are not replicated here:

- Lua plugins (`tabline`, `sessionizer`, `sessionizer-history`)
- Custom workspace history and launcher workflows
- Mouse-open-link binding
- WezTerm-specific tabline styling and status sections

Ghostty already provides sensible defaults for several of the simple bindings, so
this file stays focused on the pieces that improve day-to-day parity without
chasing feature-by-feature equivalence.

The closest port of the WezTerm pane movement is now `Ctrl+Shift+H/J/K/L` for focus,
`Alt+Shift+H/J/K/L` for resizing, and `Alt+H/J/K/L` to forward arrow keys into
the running program. Split creation stays on `Ctrl+Shift+,` and
`Ctrl+Shift+.` so the physical `<` and `>` positions still work on a US layout.

`Ctrl+Shift+O` now opens Ghostty's tab overview, which is the nearest native
equivalent to WezTerm's tab launcher/search. Lua-only WezTerm features such as
sessionizer, copy mode, and tabline remain unported.
