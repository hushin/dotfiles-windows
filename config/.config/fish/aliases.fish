abbr -a ta 'tig --all'
abbr -a tst 'tig status'
abbr -a g 'git'
abbr -a gsh 'git show'
abbr -a gdc 'git diff --cached'
abbr -a gco 'git checkout'
abbr -a gcb 'git checkout -b'
abbr -a gcm 'git checkout master'
abbr -a agh 'ag --hidden'
abbr -a tig-review "tig --reverse -w (git merge-base origin/master HEAD)...HEAD"

type -qa tac || abbr -a tac 'tail -r'

abbr -a reload 'source ~/.config/fish/config.fish'
abbr -a diff 'diff -u'
abbr -a cdu 'cd-gitroot'
abbr -a tree "tree -NC" # N: 文字化け対策, C:色をつける
abbr -a notes 'ag "TODO|HACK|FIXME|OPTIMIZE"'

abbr -a e 'emacsclient -t -a ""'
abbr -a ekill 'emacsclient -e "(kill-emacs)"'

type -qa open && abbr -a o 'open'

function f
  git ls-tree -r --name-only HEAD
end

function ef
  f | fzf | xargs -o -I% sh -c '$EDITOR %'
end

function git-review
  set -l N (git log --pretty=format:"%H %h" | grep -n $argv | cut -d : -f 1)
  git log --decorate --stat --reverse -p -$N
end
abbr -a  gre 'git-review'

function touchp
  mkdir -p (dirname "$argv") && touch "$argv"
end

function copy-history -a historyNum
  set -q historyNum[1] || set historyNum 10
  history | tail -n $historyNum | pbcopy
end

# https://github.com/junegunn/fzf/wiki/Examples-(fish)
function fssh -d "Fuzzy-find ssh host via ag and ssh into it"
  ag --ignore-case '^host [^*]' ~/.ssh/config | cut -d ' ' -f 2 | fzf | read -l result; and ssh "$result"
end

function fs -d "Switch tmux session"
  tmux list-sessions -F "#{session_name}" | fzf | read -l result; and tmux switch-client -t "$result"
end

function checkout-git-branch -d "Fuzzy-find and checkout a branch"
  git branch | grep -v HEAD | string trim | fzf --preview="git log -200 --pretty=format:%s" | read -l result; and git checkout "$result"
  commandline -f repaint
end

function checkout-recent-git-branch -d "Fuzzy-find and checkout a branch"
  git for-each-ref --format="%(refname)" --sort=-committerdate | \
  grep -v HEAD | \
  grep -v refs/tags | \
  sed -e "s|^refs/heads/||" | \
  sed -e "s|^refs/remotes/||" | \
  string trim | \
  fzf --preview='' | \
  read -l result; and git checkout -t "$result"
  commandline -f repaint
end

# https://gist.github.com/azu/09dd6f27f52e2e8d9978
function mkdev -a dirName
	if ! test "$dirName"
		echo "Usage: mkdev dir-name"
		return
	end
	set -l rootDir (ghq root)
  set -l gitUser (git config user.name)
	set -l githubUser "github.com/$gitUser"
	set -l devPath "$rootDir/$githubUser/$dirName"

	mkdir -p $devPath
	cd $devPath
  git init
end

function mksandbox -a dirName
	if ! test "$dirName"
		echo "Usage: mksandbox dir-name"
		return
	end
	set -l rootDir (ghq root)
  set -l gitUser (git config user.name)
	set -l githubUser "github.com/$gitUser-sandbox"
	set -l devPath "$rootDir/$githubUser/$dirName"

	mkdir -p $devPath
	cd $devPath
  git init
end

function crrepo
  cd-gitroot
  set -l repoName (string match -r '[^/]*/[^/]*$' "$PWD")
  hub create $argv $repoName
end

function move-to-bitbucket -d "github to bitbucket ghq directory" -a dirName
	if ! test "$dirName"
		echo "Usage: move-to-bitbucket dir-name"
		return
	end
	set -l rootDir (ghq root)
  set -l gitUser (git config user.name)
	set -l bitbucketUser "bitbucket.org/$gitUser"
  set -l path "$rootDir/$bitbucketUser/"

  mkdir -p $path
  mv $dirName $path
  cd "$path/$dirName"
end

function gwt -d "git work tree" -a branch
  set -l gitCdupDir (git rev-parse --show-cdup)
  git worktree add {$gitCdupDir}git-worktrees/$branch -b $branch
end
