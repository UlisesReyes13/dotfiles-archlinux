local actions = {}
local actionById = {}

local function add(action)
    table.insert(actions, action)
    actionById[action.id] = action
end

local function commandExists(command)
    return noctalia.commandExists(command)
end

local function dirExists(path)
    local expanded = noctalia.expandPath(path)
    local info = noctalia.fileInfo(expanded)

    return info ~= nil and info.isDir, expanded
end


-- ==========================================
-- Herramientas básicas
-- ==========================================

if commandExists("kitty") then
    add({
        id = "terminal",
        title = "Terminal",
        subtitle = "Abrir Kitty",
        glyph = "terminal-2",
        cmd = { "kitty" }
    })
end

if commandExists("firefox") then
    add({
        id = "firefox",
        title = "Firefox",
        subtitle = "Abrir navegador",
        glyph = "brand-firefox",
        cmd = { "firefox" }
    })
end

if commandExists("thunar") then
    add({
        id = "files",
        title = "Archivos",
        subtitle = "Abrir Thunar",
        glyph = "folder",
        cmd = { "thunar" }
    })
end

if commandExists("code") then
    add({
        id = "vscode",
        title = "Visual Studio Code",
        subtitle = "Abrir VS Code",
        glyph = "brand-vscode",
        cmd = { "code" }
    })
end


-- ==========================================
-- Administración / monitoreo
-- ==========================================

if commandExists("btop") and commandExists("kitty") then
    add({
        id = "btop",
        title = "Monitor del sistema",
        subtitle = "Abrir btop",
        glyph = "activity",
        cmd = { "kitty", "-e", "btop" }
    })
end

if commandExists("docker") and commandExists("kitty") then
    add({
        id = "docker-ps",
        title = "Docker: contenedores",
        subtitle = "Mostrar docker ps",
        glyph = "brand-docker",
        cmd = {
            "kitty",
            "-e",
            "sh",
            "-lc",
            "docker ps; echo; printf 'Presiona Enter para cerrar...'; read _"
        }
    })

    add({
        id = "docker-stats",
        title = "Docker: recursos",
        subtitle = "Mostrar docker stats",
        glyph = "chart-bar",
        cmd = {
            "kitty",
            "-e",
            "docker",
            "stats"
        }
    })
end


-- ==========================================
-- Carpetas de proyectos
-- Solo aparecen cuando realmente existen
-- ==========================================

local projectFolders = {
    {
        id = "projects-work",
        title = "Proyectos de trabajo",
        path = "~/Documentos/projects/work"
    },
    {
        id = "projects",
        title = "Proyectos",
        path = "~/Documentos/projects"
    },
    {
        id = "proyectos",
        title = "Proyectos",
        path = "~/Documentos/proyectos"
    }
}

for _, project in ipairs(projectFolders) do
    local exists, path = dirExists(project.path)

    if exists then
        if commandExists("kitty") then
            add({
                id = project.id .. "-terminal",
                title = project.title,
                subtitle = "Abrir terminal en " .. path,
                glyph = "folder-code",
                cmd = {
                    "kitty",
                    "--directory",
                    path
                }
            })
        end

        if commandExists("code") then
            add({
                id = project.id .. "-code",
                title = project.title .. " — VS Code",
                subtitle = path,
                glyph = "brand-vscode",
                cmd = {
                    "code",
                    path
                }
            })
        end
    end
end


-- ==========================================
-- Launcher
-- ==========================================

function onQuery(text)
    local results = {}
    local query = string.lower(text)

    for index, action in ipairs(actions) do
        local searchable =
            action.title .. " " ..
            (action.subtitle or "")

        local score

        if query == "" then
            score = 1000 - index
        else
            score = noctalia.fuzzyScore(query, searchable)
        end

        if score ~= nil then
            table.insert(results, {
                id = action.id,
                title = action.title,
                subtitle = action.subtitle,
                glyph = action.glyph,
                score = score
            })
        end
    end

    launcher.setResults(text, results)
end


function onActivate(id)
    local action = actionById[id]

    if action == nil then
        return
    end

    noctalia.runAsync(action.cmd)
end
