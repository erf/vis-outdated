# vis-outdated

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to check if a list of git repos (your favorite vis-plugins?) are up to date.

## Commands

**out-ls** - list repos with outdated-status

**out-up** - update repo list with latest commit hash

## How

Given a list of git repos, we download the latest commit hash per repo using `git ls-remote` and store them in a local CSV cache `~/.vis-outdated`.

If the local hash does not match with the latest, we show it as outdated.

A update command lets you update all the repos to the latest hash.

## Local cache date structure

| url | hash |
|-----|------|
| https://github.com/martanne/vis.git | 3fe8d2ecb9fafc67b2731419a47a1b467f381dae |
| https://github.com/erf/vis-cursors.git |f36f51f60070298bb19fb92f58acc06e8dc6a0c6 |

## git commands

### get latest git hash

git rev-parse --short HEAD

### get lateat git hash without cloning

git ls-remote https://github.com/martanne/vis.git HEAD

git ls-remote https://github.com/martanne/vis.git HEAD | awk '{ print $1}'

git ls-remote https://github.com/martanne/vis.git HEAD | cut -f1

