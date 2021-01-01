export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export OTHER_REPOS=("my-project" "my-other-project")

# Values to make outputs color coded.
RED='\033[0;31m'
NC='\033[0m'

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias clearBranches='git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D'

# Typically, I like to create aliases for my projects so I can easily switch between
# multiple projects relatively quickly. For example, this is how I would switch to a project
# folder named "janet".
# alias j='cd ~/Desktop/Projects/janet'

# A collection of aliases used to quickly switch between git branches,
# assist in adding files and checking git status.
alias bm='git checkout main'
alias bd='git checkout dev'
alias s='git status'
alias a='git add .'

source ~/.profile
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

# Function to switch quickly to an already existing branch. If certain repos require a prefix for the branch,
# or different prefixs you can specify them in the OTHER_REPOS variable.
#
# EXAMPLE USAGE:
# In repo named my-project
#   `b new-feature` => `git checkout PROJECTPREFIX-new-feature`
# In repo named something-else-project
#   `b new-feature` => `git checkout new-feature`
function b() {
  repo=$(basename `git rev-parse --show-toplevel`)

  if [[ " ${OTHER_REPOS[@]} " =~ " ${repo} " ]]; then
    git checkout PROJECTPREFIX-$1
  else
    git checkout $1
  fi
}

# Function to quickly create a branch. If certain repos require a prefix for the branch,
# or different prefixs you can specify them in the OTHER_REPOS variable.
#
# EXAMPLE USAGE:
# In repo named my-project
#   `nb new-feature` => `git checkout -b PROJECTPREFIX-new-feature`
# In repo named something-else-project
#   `nb new-feature` => `git checkout -b new-feature`
function nb() {
  repo=$(basename `git rev-parse --show-toplevel`)

  if [[ " ${OTHER_REPOS[@]} " =~ " ${repo} " ]]; then
    git checkout -b PROJECTPREFIX-$1
  else
    git checkout -b $1
  fi
}

# Function to quickly push changes out to the remote repository. Function will prevent
# a push onto the main branch
#
# EXAMPLE USAGE:
# `p` => `git push`
function p() {
  current=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current" == "main" ]
  then
    echo -e "${RED}YOU CANNOT DIRECTLY PUSH TO MAIN.${NC}"
  else
    git push
  fi
}

# Function to quickly push a new branch up out to the remote repository. Function will prevent
# a push onto the main branch
#
# EXAMPLE USAGE:
# `pb` => `git push -u origin new-branch`
function pb() {
  current=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current" == "main" ]
  then
    echo -e "${RED}YOU CANNOT DIRECTLY PUSH TO MAIN.${NC}"
  else
    git push -u origin $current
  fi
}

# Function to quickly commit to the current branch, prefixed with the current branch name.
# Function will prevent a commit on the main branch.
#
# EXAMPLE USAGE:
# `c "Initial Commit"` => `git commit -m "branch_name: Initial Commit"`
function c() {
  current=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current" == "main" ]
  then
    echo -e "${RED}YOU CANNOT DIRECTLY COMMIT TO MAIN.${NC}"
  else
    git commit -m "$current: $1"
  fi
}

# Function will cherry-pick the given SHA. Function prevents main branch from being used.
#
# EXAMPLE USAGE:
# `cp shaid` => `git cherry-pick shaid`
function cp() {
  current=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current" == "main" ]
  then
    echo -e "${RED}YOU CANNOT DIRECTLY COMMIT TO MASTER.${NC}"
  else
    git cherry-pick $1
  fi
}

# Function will pull the main branch switcing back to the currently viewed branch.
# If there are existing changes, it will stash them.
#
# EXAMPLE USAGE:
# `pm`
function pm() {
  current=$(git rev-parse --abbrev-ref HEAD)
  git stash
  git checkout main
  git pull
  git checkout $current
}

# Function will open the URL to create a new PR for the current repo on the current branch.
#
# EXAMPLE USAGE:
# `npr`
function npr() {
  repo_url=$(git config --get remote.origin.url)
  branch=$(git rev-parse --abbrev-ref HEAD)
${var1%.out}
  open "${repo_url%.git}/pull/new/$branch"
}

# Function will copy the current commit URL path to the clipboard.
#
# EXAMPLE USAGE:
# `cgc`
function cgc() {
 commit_link | pbcopy
}

# Function will "go to" the current commit URL path.
#
# EXAMPLE USAGE:
# `gc`
function gc() {
  repo_url=$(git config --get remote.origin.url)
  commit_sha=$(git rev-parse HEAD)

  open "${repo_url%.git}/commit/$commit_sha"
}

# Function will copy the current commit SHA to the clipboard.
#
# EXAMPLE USAGE:
# `csha`
function csha() {
  commit_sha=$(git rev-parse HEAD)

  echo $commit_sha | pbcopy
}

# Opens the current repository in the browser.
#
# # EXAMPLE USAGE:
# `or`
function or() {
  repo_url=$(git config --get remote.origin.url)

  open ${repo_url%.git}
}

# Helper function that returns the current commit link.
function commit_link() {
  repo_url=$(git config --get remote.origin.url)
  commit_sha=$(git rev-parse HEAD)

  echo "${repo_url%.git}/commit/$commit_sha"
}

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
