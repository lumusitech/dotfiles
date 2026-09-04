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
--

-- QuickNotes
o.window({ title = "^QuickNotes$" }, {
  workspace = "special:notes",
  float = true,
  size = { 1000, 650 },
  center = true,
})

-- YouTube Music
o.window({ class = "chrome-music.youtube.com__-Default" }, {
  workspace = "special:music",
  float = true,
  size = { 1200, 750 },
  center = true,
})

-- WhatsApp Web
o.window({ class = "chrome-web.whatsapp.com__-Default" }, {
  workspace = "special:whatsapp",
  float = true,
  size = { 1100, 750 },
  center = true,
})

-- Cliamp (identificado por su app-id dedicado)
o.window({ class = "^cliamp-scratchpad$" }, {
  workspace = "special:cliamp",
  float = true,
  size = { 900, 550 },
  center = true,
})

-- Calculadora nativa (omacalc)
o.window({ class = ".*omacalc.*" }, {
  workspace = "special:calc",
  float = true,
  size = { 380, 580 },
  center = true,
})


