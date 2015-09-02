export PATH="/usr/local/mysql/bin:$PATH"

alias gcd='git checkout develop'

alias gmm='echo git merging origin branch to master;echo ;echo -- checkout master --;git checkout master&&echo -- git pull -- &&  git pull&&echo --git merge--&& git merge'
alias gmd='echo git merging origin branch to develop;echo ;echo -- checkout develop --;git checkout develop&&echo -- git pull --&&  git pull&&echo --git merge--&& git merge'


# show list of files that have conflicts
gdf="git diff --name-only --diff-filter=U"

# pull and merge a branch into another branch
function git_merge_branchs() {
  git rev-parse --show-toplevel #first line has to be a git command for auto complete o work
  if [ -z $1 ]
    then
    echo "sorry you didn't give me a branch to merge into develop"
  else
    echo "\n-------\nremote update\n-------" \
    && git remote update  \
    && echo "\n-------\ncheckout $2\n-------"  \
    && git checkout $2 \
    && echo "\n-------\npull $2\n-------"  \
    && git pull \
    && echo "\n-------\ncheckout $1\n-------"  \
    && git checkout $1 \
    && echo "\n-------\npull $1\n-------"  \
    && git pull   \
    && echo "\n-------\nmerge $2 into $1\n-------"  \
    && git merge --no-ff $2
  fi
}
function gm2b(){
  echo "merge $2 into $1? (y/n)";
  read sure;
  if  [[ $sure == "y" ]];
  then
    git_merge_branchs $1 $2;
  fi
}
compdef _git gm2b=git-merge

# pull branch specified and merge to master
function gm2m (){
  git rev-parse --show-toplevel #first line has to be a git command for auto complete o work
  BRANCH=$1;
  if [ -z $1 ]
  then
    echo "sorry you didn't give me a branch to merge into master"
  else
     git_merge_branchs $1 master;
  fi
}
compdef _git gm2m=git-merge

# pull branch specified and merge to develop-new
function gm2dn (){
  git rev-parse --show-toplevel #first line has to be a git command for auto complete o work
  BRANCH=$1;
  if [ -z $1 ]
  then
    echo "sorry you didn't give me a branch to merge into develop-new"
  else
    git_merge_branchs $1 develop-new;
  fi
}
compdef _git gm2dn=git-merge


# pull branch specified and merge to develop
function gm2d (){
  git rev-parse --show-toplevel #first line has to be a git command for auto complete o work
  BRANCH=$1;
  if [ -z $1 ]
  then
    echo "sorry you didn't give me a branch to merge into develop"
  else
    git_merge_branchs $1 develop;
  fi
}
compdef _git gm2d=git-merge


function gk() {
  if [ -z $1 ]
  then
    git remote update \
    && echo "git remote updated\n" \
    && echo "running gitk --all --branches" \
    && gitk --all --branches
  else
    cd $1 \
    && echo "moved folder to $1" \
    && git remote update \
    && echo "git remote updated" \
    && echo "running gitk --all --branches" \
    && gitk --all --branches 
  fi
}

function gx() {
  if [ -z $1 ]
  then
    git remote update \
    && echo "git remote updated\n" \
    && echo "running gitx --all" \
    && gitx --all
  else
    cd $1 \
    && echo "moved folder to $1" \
    && git remote update \
    && echo "git remote updated" \
    && echo "running gitx --all" \
    && gitx --all 
  fi
}

function gb2b() {
  if [ -z $1 ]
  then
    echo "sorry you didn't give me a branch to merge into develop"
  else
    echo "\n-------\nremote update\n-------" \
    && git remote update  \
    && echo "\n-------\ncheckout beanstalk/$1\n-------"  \
    && git checkout beanstalk/$1 \
    && echo "\n-------\npull changes from bitbucket \n-------"  \
    && git pull bitbucket $1 \
    && echo "\n-------\npush changes to bitbucket\n-------"  \
    && git push beanstalk $1 
  fi
}

