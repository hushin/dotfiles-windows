# fzf
set -x FZF_DEFAULT_COMMAND 'ag -g "" --hidden --ignore ".git"'
set -x FZF_DEFAULT_OPTS "--height 70% --layout=reverse --border --ansi --inline-info"

# editor
set -x EDITOR 'emacsclient -t -a ""'

# theme
# bobthefish
set -g theme_color_scheme zenburn
set -g theme_display_date no

# gabbr
set -U gabbr_config $HOME/.config/fish/gabbr.conf

# color
set -g fish_color_command --bold
