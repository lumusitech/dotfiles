-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Configuración específica para monitor ASUS VA27EHE a 75Hz nativos
hl.monitor({
    output = "desc:ASUSTek COMPUTER INC ASUS VA27EHE L8LMTF116411",
    mode = "1920x1080@75",
    position = "0x0",
    scale = omarchy_monitor_scale,
    vrr = 1, -- 1 = On / Adaptive Sync (FreeSync compatible con tu ASUS VA27EHE)
})

-- Fallback genérico para cualquier otra pantalla
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})
