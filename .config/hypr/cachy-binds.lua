-- ==========================================
-- Atajos estilo CachyOS + Noctalia
-- ==========================================

local ipc = "noctalia msg "

-- ==========================================
-- Quitar binds previos que puedan chocar
-- ==========================================

hl.unbind("SUPER + Q")
hl.unbind("SUPER + RETURN")
hl.unbind("SUPER + W")
hl.unbind("SUPER + SPACE")
hl.unbind("SUPER + F")
hl.unbind("SUPER + ALT + SPACE")
hl.unbind("SUPER + P")
hl.unbind("SUPER + V")
hl.unbind("SUPER + A")
hl.unbind("SUPER + N")
hl.unbind("SUPER + B")
hl.unbind("SUPER + SHIFT + A")
hl.unbind("SUPER + ALT + C")
hl.unbind("Print")
hl.unbind("SUPER + Print")

-- ==========================================
-- Aplicaciones
-- ==========================================

hl.bind(
    "SUPER + RETURN",
    hl.dsp.exec_cmd("kitty")
)

hl.bind(
    "SUPER + W",
    hl.dsp.exec_cmd("firefox")
)

-- Launcher de Noctalia
hl.bind(
    "SUPER + SPACE",
    hl.dsp.exec_cmd(ipc .. "panel-toggle launcher")
)

-- ==========================================
-- Ventanas
-- ==========================================

hl.bind(
    "SUPER + Q",
    hl.dsp.window.close()
)

hl.bind(
    "SUPER + F",
    hl.dsp.window.fullscreen({
        action = "toggle",
        mode = "fullscreen"
    })
)

hl.bind(
    "SUPER + ALT + SPACE",
    hl.dsp.window.float({
        action = "toggle"
    })
)

-- ==========================================
-- Mover ventanas
-- ==========================================

hl.bind(
    "SUPER + SHIFT + left",
    hl.dsp.window.move({ direction = "left" })
)

hl.bind(
    "SUPER + SHIFT + right",
    hl.dsp.window.move({ direction = "right" })
)

hl.bind(
    "SUPER + SHIFT + up",
    hl.dsp.window.move({ direction = "up" })
)

hl.bind(
    "SUPER + SHIFT + down",
    hl.dsp.window.move({ direction = "down" })
)

-- ==========================================
-- Bloqueo
-- ==========================================

hl.bind(
    "SUPER + L",
    hl.dsp.exec_cmd("hyprlock")
)

-- ==========================================
-- Workspaces 1-9
-- ==========================================

for i = 1, 9 do
    local ws = tostring(i)

    hl.bind(
        "SUPER + ALT + " .. ws,
        hl.dsp.focus({
            workspace = ws
        })
    )
end

-- ==========================================
-- Noctalia
-- ==========================================

-- Control Center
hl.bind(
    "SUPER + A",
    hl.dsp.exec_cmd(ipc .. "panel-toggle control-center")
)

-- Portapapeles
hl.bind(
    "SUPER + V",
    hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard")
)

-- Menú de sesión
hl.bind(
    "SUPER + ALT + C",
    hl.dsp.exec_cmd(ipc .. "panel-toggle session")
)

-- Red / Wi-Fi
hl.bind(
    "SUPER + N",
    hl.dsp.exec_cmd(ipc .. "panel-toggle control-center network")
)

-- Bluetooth
hl.bind(
    "SUPER + B",
    hl.dsp.exec_cmd(ipc .. "panel-toggle control-center bluetooth")
)

-- Audio
hl.bind(
    "SUPER + SHIFT + A",
    hl.dsp.exec_cmd(ipc .. "panel-toggle control-center audio")
)

-- ==========================================
-- Capturas de pantalla
-- ==========================================

-- Región
hl.bind(
    "Print",
    hl.dsp.exec_cmd(ipc .. "screenshot-region")
)

-- Pantalla completa
hl.bind(
    "SUPER + Print",
    hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen")
)

-- ==========================================
-- Selector de color
-- ==========================================

hl.bind(
    "SUPER + P",
    hl.dsp.exec_cmd("hyprpicker -a")
)

-- ==========================================
-- Teclas multimedia -> Noctalia
-- ==========================================

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(ipc .. "volume-up")
)

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(ipc .. "volume-down")
)

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd(ipc .. "volume-mute")
)

hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd(ipc .. "brightness-up")
)

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd(ipc .. "brightness-down")
)

-- ==========================================
-- Gestos estilo CachyOS
-- ==========================================

hl.gesture({
    fingers = 4,
    direction = "horizontal",
    action = "workspace"
})

hl.gesture({
    fingers = 3,
    direction = "down",
    action = "close"
})

hl.gesture({
    fingers = 3,
    direction = "up",
    action = "fullscreen"
})

hl.gesture({
    fingers = 3,
    direction = "left",
    action = "float"
})

hl.unbind("SUPER + SHIFT + W")

hl.bind(
    "SUPER + SHIFT + W",
    hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper")
)

hl.unbind("SUPER + D")

hl.bind(
    "SUPER + D",
    hl.dsp.exec_cmd("noctalia msg dock-toggle")
)

-- Dev Launcher
hl.unbind("SUPER + SHIFT + D")

hl.bind(
    "SUPER + SHIFT + D",
    hl.dsp.exec_cmd([[noctalia msg panel-toggle launcher "/dev "]])
)


