-- Tema ligero estilo CachyOS

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 2,
        layout = "dwindle",

        col = {
            active_border = "#7aa2f7ff",
            inactive_border = "#3b4261aa",
        },
    },

    decoration = {
        rounding = 10,
        rounding_power = 2.5,

        active_opacity = 1.0,
        inactive_opacity = 0.97,

        blur = {
            enabled = false,
        },

        shadow = {
            enabled = false,
        },
    },
})

hl.curve("quick", {
    type = "bezier",
    points = {
        { 0.25, 0.1 },
        { 0.25, 1.0 }
    }
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 2.5,
    bezier = "quick",
    style = "popin 92%"
})

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 2,
    bezier = "quick"
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 3,
    bezier = "quick",
    style = "slidefade 15%"
})
