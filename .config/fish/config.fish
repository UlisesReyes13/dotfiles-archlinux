# ==========================================
# Fish
# ==========================================

if status is-interactive
    starship init fish | source
    zoxide init fish | source

    # ~/.local/bin
    fish_add_path ~/.local/bin

    # Aliases
    alias cls='clear'
    alias ls='eza --icons'
    alias ll='eza -lah --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias tree='eza --tree --icons'

    # Git
    abbr -a gs 'git status'
    abbr -a ga 'git add'
    abbr -a gaa 'git add .'
    abbr -a gc 'git commit'
    abbr -a gp 'git push'
    abbr -a gl 'git pull'
    abbr -a gd 'git diff'
    abbr -a gco 'git checkout'

    # Docker, para cuando lo instalemos
    abbr -a dps 'docker ps'
    abbr -a dc 'docker compose'
    abbr -a dcu 'docker compose up -d'
    abbr -a dcd 'docker compose down'
end
