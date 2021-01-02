# vis-outdated

Keep up-to-date with a list of git repos using [vis](https://github.com/martanne/vis).

## How

Given a set of *git* repos, we fetch commit hashes using `git ls-remote` and store them on disk. 

We then compare the local cache with the latest hashes to see if they are up-to-date.

## Commands

**outdated** - compare local hashes to latest

**outdated-update** - update local hashes from latest

## Config

Just set `repos` to an array of git repositories

``` lua
require('plugins/vis-outdated').repos = {
	'https://github.com/erf/vis-title',
	'https://github.com/erf/vis-cursors',
	'https://github.com/erf/vis-highlight',
}
```

`github` urls can be shortend to only `{name}/{repo}`

``` lua
require('plugins/vis-outdated').repos = {
	'erf/vis-title',
	'erf/vis-cursors',
	'erf/vis-highlight',
}
```

## Local CSV cache file

*repos* and *commits* are cached in `{XDG_CACHE_HOME|HOME}.vis-outdated.csv`.