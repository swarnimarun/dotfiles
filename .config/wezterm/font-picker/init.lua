-- font-picker: switch the WezTerm font from a fuzzy selector menu, live (no restart)
-- and remember the choice across restarts.
--
--   local fp = wezterm.plugin.require("font-picker")
--   fp.setup({
--     fonts = { "JetBrains Mono", { family = "Nordwand Mono", weight = "Medium" } },
--     fallback = { "JetBrains Mono", "Symbols Nerd Font Mono" },
--     weights = { "Regular" },            -- optional: expand each family into weight variants
--   })
--   fp.apply_saved(config)                -- honour the last pick on start-up
--   config.keys = { { key = "f", mods = "ALT|SHIFT", action = fp.picker() } }

local wezterm = require("wezterm")

local M = {}

local state = {
  fonts = {},
  weights = {},
  fallback = {},
  state_file = wezterm.config_dir .. "/.font-picker.state",
  title = "Font",
  index = 1,
}

---------------------------------------------------------------------------
-- state file: line 1 = family, line 2 = weight, rest = fallback families
---------------------------------------------------------------------------

local function read_state()
  local f = io.open(state.state_file, "r")
  if not f then
    return nil
  end
  local lines = {}
  for line in f:lines() do
    lines[#lines + 1] = line
  end
  f:close()
  if not lines[1] or lines[1] == "" then
    return nil
  end
  local fallback = {}
  for i = 3, #lines do
    if lines[i] ~= "" then
      fallback[#fallback + 1] = lines[i]
    end
  end
  return { family = lines[1], weight = lines[2], fallback = fallback }
end

local function write_state(entry)
  local ok, err = pcall(function()
    local f = assert(io.open(state.state_file, "w"))
    f:write(entry.family, "\n", entry.weight or "Regular", "\n")
    for _, fam in ipairs(entry.fallback) do
      f:write(fam, "\n")
    end
    f:close()
  end)
  if not ok then
    wezterm.log_error("font-picker: could not save state: " .. tostring(err))
  end
end

---------------------------------------------------------------------------
-- normalisation
---------------------------------------------------------------------------

-- Accepts "Family", { family = "...", weight = "..." },
-- or { label = "...", font = <wezterm font or font_with_fallback table> }.
local function normalize(spec, weights, fallback)
  if type(spec) == "string" then
    spec = { family = spec }
  end

  local entry = { label = spec.label }

  if spec.font then
    entry.font = spec.font
    entry.family = spec.label or "custom"
    entry.weight = spec.weight or "Regular"
    entry.fallback = fallback
    return entry
  end

  entry.family = spec.family
  entry.weight = spec.weight or "Regular"

  local fams = { { family = entry.family, weight = entry.weight } }
  for _, fam in ipairs(fallback) do
    if fam ~= entry.family then
      fams[#fams + 1] = { family = fam }
    end
  end
  entry.font = wezterm.font_with_fallback(fams)
  entry.fallback = fallback
  entry.label = entry.label or entry.family
  if not spec.label and (entry.weight or "Regular") ~= "Regular" then
    entry.label = entry.family .. " " .. entry.weight
  end
  return entry
end

local function build_entries()
  local entries, seen = {}, {}
  for _, spec in ipairs(state.fonts) do
    local base = type(spec) == "string" and { family = spec } or spec
    if base.font then
      local entry = normalize(base, state.weights, state.fallback)
      if not seen[entry.label] then
        seen[entry.label] = true
        entries[#entries + 1] = entry
      end
    else
      local variants = base.weight and { base } or nil
      if not variants then
        variants = {}
        for _, w in ipairs(state.weights) do
          variants[#variants + 1] = { family = base.family, weight = w }
        end
      end
      for _, variant in ipairs(variants) do
        local entry = normalize(variant, state.weights, state.fallback)
        if not seen[entry.label] then
          seen[entry.label] = true
          entries[#entries + 1] = entry
        end
      end
    end
  end
  return entries
end

---------------------------------------------------------------------------
-- applying a font
---------------------------------------------------------------------------

local function apply_entry(entry, window)
  local overrides = { font = entry.font }
  -- set_config_overrides replaces (does not merge) the previous overrides, so
  -- everything this plugin changes has to be re-sent on every switch.
  if window then
    pcall(function()
      window:set_config_overrides(overrides)
    end)
  end
  local ok, windows = pcall(wezterm.gui.gui_windows)
  if ok then
    for _, win in ipairs(windows) do
      if win ~= window then
        pcall(function()
          win:set_config_overrides(overrides)
        end)
      end
    end
  end
  write_state(entry)
  wezterm.log_info("font-picker: switched to " .. entry.label)
end

---------------------------------------------------------------------------
-- public API
---------------------------------------------------------------------------

function M.setup(opts)
  opts = opts or {}
  state.fonts = opts.fonts or { "JetBrains Mono" }
  state.weights = opts.weights or { "Regular" }
  state.fallback = opts.fallback or {}
  state.state_file = opts.state_file or state.state_file
  state.title = opts.title or state.title
  return M
end

-- Apply the remembered font to a config table (call before `return config`).
function M.apply_saved(config)
  local saved = read_state()
  if not saved then
    return config
  end
  local entry = normalize(
    { family = saved.family, weight = saved.weight },
    state.weights,
    #saved.fallback > 0 and saved.fallback or state.fallback
  )
  config.font = entry.font
  return config
end

-- The selector menu action.
function M.picker()
  local entries = build_entries()
  local by_id, choices = {}, {}
  local current = read_state()
  for i, entry in ipairs(entries) do
    by_id[i] = entry
    local label = entry.label
    if current and current.family == entry.family and (current.weight or "Regular") == entry.weight then
      label = "● " .. label
    end
    choices[i] = { label = label }
  end

  return wezterm.action.InputSelector({
    title = state.title,
    fuzzy = true,
    choices = choices,
    action = wezterm.action_callback(function(window, _pane, id, label)
      local entry = by_id[tonumber(id)]
      if not entry then
        for _, e in ipairs(entries) do
          if e.label == label or ("● " .. e.label) == label then
            entry = e
            break
          end
        end
      end
      if entry then
        apply_entry(entry, window)
      end
    end),
  })
end

-- Cycle through the list: +1 next, -1 previous.
function M.cycle(step)
  return wezterm.action_callback(function(window)
    local entries = build_entries()
    if #entries == 0 then
      return
    end
    local current = read_state()
    local idx = 1
    for i, entry in ipairs(entries) do
      if current and current.family == entry.family and (current.weight or "Regular") == entry.weight then
        idx = i
        break
      end
    end
    local next_idx = ((idx - 1 + (step or 1)) % #entries) + 1
    apply_entry(entries[next_idx], window)
  end)
end

-- List the entry labels that the menu will offer, in order.
function M.labels()
  local labels = {}
  for _, entry in ipairs(build_entries()) do
    labels[#labels + 1] = entry.label
  end
  return labels
end

-- Return the font object (with fallbacks) for a label, or nil.
function M.font_for(label)
  for _, entry in ipairs(build_entries()) do
    if entry.label == label then
      return entry.font
    end
  end
end

-- Apply a font by label, without the menu (handy for scripting).
function M.apply_label(label, window)
  for _, entry in ipairs(build_entries()) do
    if entry.label == label then
      apply_entry(entry, window)
      return true
    end
  end
  return false
end

return M
