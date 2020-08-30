# FIXME 動かなくなったので一時的に無効化
# bind \x1b 'fzf_recentd' # Ctrl-[にバインドする
bind \cj 'fzf_recentd'
bind \c] 'FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview \'bat --color=always --style=header,grid --line-range :80 (ghq root)/{}/README.*\'" fzf_ghq'
bind \et 'FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview \'bat --color=always --style=header,grid --line-range :80 {}\'" __fzf_find_file'
bind \cr '__fzf_reverse_isearch'
bind \eo '__fzf_cd'
bind \eO '__fzf_cd --hidden'
bind \co '__fzf_open'
bind \cO '__fzf_open --editor'
bind \cs\cs fssh
bind \cg\cb checkout-git-branch
bind \cg\cg\cb checkout-recent-git-branch
