# vis-outdated

Keep a list of git-repos (plugins) you want to follow, you can list if the repos are outdated and also update the list to latest.

## Commands

**out-ls** - shows you you a list of repos with their status

**out-up** - update the list to latest commit (without downloading the whole repo)

## How it works

Given a list of git repos, we download the latest commit hash per repo using `git ls-remote`.

If the local hash does not match with the latest, we show it as outdated.

A update (up) command lets you update all the repos to the latest hash.

## git commands

### get latest git hash

git rev-parse --short HEAD

### get lateat git hash without cloning

git ls-remote https://github.com/martanne/vis.git HEAD

git ls-remote https://github.com/martanne/vis.git HEAD | awk '{ print $1}'

git ls-remote https://github.com/martanne/vis.git HEAD | cut -f1

