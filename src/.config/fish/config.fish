# Disable help greeting
set -g fish_greeting ""

# Abbreviations 
abbr -a gdb 'gdb -q'
abbr -a val valgrind
abbr -a str strace
abbr -a ltr ltrace

# Aliases
alias q='exit'
alias c='clear'
alias rm='rm -rvf'

alias cat='bat'
alias grep='rg'
alias find='fd'
alias f='fzf'

alias cd='z'
alias home='cd ~'
alias projects='cd ~/projects'
alias downloads='cd ~/Downloads'
alias dls='cd ~/Downloads'
alias documents='cd ~/Documents'
alias docs='cd ~/Documents'

alias ls='exa --color=auto --icons'
alias ll='ls -la'
alias la='ls -la'
alias ..='cd ..'
alias ...='cd ../..'

# Rust aliases 
alias cr='cargo run'
alias cb='cargo build'
alias ca='cargo add'
alias cn='cargo new'
alias ci='cargo init'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gcl='git clone'

# Set editor
set -gx EDITOR nvim

# Add local bin to PATH if it exists
if test -d ~/.local/bin
    fish_add_path ~/.local/bin
end

set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'

if command -v fd > /dev/null
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --follow --exclude .git'
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Hex dump with colors
function hex
    if command -v hexyl > /dev/null
        hexyl $argv
    else
        xxd $argv | bat --language hexdump
    end
end

# Memory layout of ELF
function elfinfo
    readelf -a $argv[1] | bat --language yaml
end

# Quick size analysis
function binsize
    size $argv[1]
    file $argv[1]
    ls -lh $argv[1]
end

# Strip and compare sizes
function stripcomp
    if test (count $argv) -eq 0
        echo "Usage: stripcomp <binary>"
        return 1
    end
    set original_size (stat -f%z $argv[1] 2>/dev/null || stat -c%s $argv[1])
    cp $argv[1] $argv[1].original
    strip $argv[1]
    set stripped_size (stat -f%z $argv[1] 2>/dev/null || stat -c%s $argv[1])
    echo "Original: $original_size bytes"
    echo "Stripped: $stripped_size bytes"
    echo "Saved: "(math $original_size - $stripped_size)" bytes"
end

# Disassemble binary
function disasm
    if test (count $argv) -eq 0
        echo "Usage: disasm <binary>"
        return 1
    end
    objdump -d -M intel $argv[1] | bat --language asm
end

# Show assembly from C code
function showasm
    if test (count $argv) -eq 0
        echo "Usage: showasm <file.c>"
        return 1
    end
    gcc -S -masm=intel -fverbose-asm -O2 $argv[1] -o - | bat --language asm
end

starship init fish | source
zoxide init fish | source
