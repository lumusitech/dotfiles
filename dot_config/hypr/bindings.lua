-- ==========================================
-- Scratchpads Dedicados
-- ==========================================

-- QuickNotes (SUPER + N)
hl.unbind("SUPER + SHIFT + N")
o.bind("SUPER + N", "Toggle Notes", "bash ~/.local/bin/toggle-notes")

-- YouTube Music (SUPER + M)
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + M", "Toggle YT Music", "bash ~/.local/bin/toggle-ytmusic")

-- WhatsApp Web (SUPER + ALT + M)
o.bind("SUPER + ALT + M", "Toggle WhatsApp", "bash ~/.local/bin/toggle-whatsapp")

-- Calculadora (SUPER + ALT + C)
o.bind("SUPER + ALT + C", "Toggle Calculator", "bash ~/.local/bin/toggle-calc")

-- Cliamp (SUPER + R)
hl.unbind("SUPER + R")
o.bind("SUPER + R", "Toggle Cliamp", "bash ~/.local/bin/toggle-cliamp")

-- Reemplazar ChatGPT por Gemini Webapp
hl.unbind("SUPER + SHIFT + A")
o.bind("SUPER + SHIFT + A", "Launch Gemini", "omarchy-launch-webapp https://gemini.google.com/")

-- Voxtype Dictation & Translation (Push-to-Talk)
if o.cmd_present("voxtype") then
  -- F9: Español directo (Push-to-Talk)
  o.bind("F9", "Start dictation (ES)", "voxtype record start")
  o.bind("F9", "Stop dictation (ES)", "voxtype record stop", { release = true })

  -- F10: Traducción a Inglés (Push-to-Talk)
  o.bind("F10", "Start translation (EN)", "voxtype record start --profile translate")
  o.bind("F10", "Stop translation (EN)", "voxtype record stop", { release = true })
end
