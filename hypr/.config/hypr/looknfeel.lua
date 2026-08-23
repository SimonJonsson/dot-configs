-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- Cap a lone window at 16:9 (~1966 px of the 2732 usable) on the 3440x1440
-- ultrawide, so it stays readable without stretching edge to edge.
--
-- Omarchy's single-window-aspect-ratio toggle forces 1:1, which is far too
-- narrow here. It is off; toggles load after this file, so turning it back on
-- with CTRL ALT + BACKSPACE still gives the square, and turning it off returns
-- to 16:9.
hl.config({
  layout = {
    single_window_aspect_ratio = { 16, 9 },
  },
})

-- Default layout is scrolling (niri-like side row). ALT+I toggles to
-- dwindle per workspace (custom binding in bindings.lua); the choice is
-- remembered in ~/.local/state/omarchy/workspace-layouts/.
hl.config({
  general = {
    layout = "scrolling",
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#group
-- A group stacks its windows into one tile and its bar eats height off the
-- window. Omarchy's default renders window titles at 22px and costs 28px in
-- total, which is a lot when the group *is* the window. With titles off the
-- `height` setting is ignored entirely and the bar collapses to the indicator,
-- so indicator_height alone decides the cost: a 9px strip, one segment per
-- window, the active one highlighted. Still a third of the stock 28px.
--
-- Note indicator_gap adds *vertical* space (it took the cost back up to 9px),
-- so it stays at 0; gaps_in is what separates the segments horizontally.
-- Setting indicator_height to 0 as well makes the bar vanish completely.
--
-- Colours are read back from the theme's own group borders, so the bar keeps
-- following `omarchy theme set` rather than pinning a palette here.
hl.config({
  group = {
    groupbar = {
      render_titles = false,
      indicator_height = 9,
      indicator_gap = 0,
      gaps_in = 2,
      gaps_out = 0,
      gradients = false,
      rounding = 0,
      col = {
        active = hl.get_config("group:col.border_active"),
        inactive = hl.get_config("group:col.border_inactive"),
      },
    },
  },
})
