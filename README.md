# vis-outdated 🕷️

Keep up-to-date with a list of git repos using [vis](https://github.com/martanne/vis).

## How

Given a set of *git* repos, we fetch commit hashes using `git ls-remote` and store them on disk. 

We then compare the local hashes with the latest remote hashes to see if they are up-to-date.

## Commands

**outdated** - are we up-to-date?

**outdated-up** - update local hashes

### Bonus

**outdated-install** - do a git clone (shallow) to **vis** `plugins` folder (no overwrite)

## Config

Just set `repos` to an array of git repositories.

Example:

``` lua
require('plugins/vis-outdated').repos = {
	'https://github.com/erf/vis-title',
	'https://github.com/erf/vis-cursors',
	'https://github.com/erf/vis-highlight',
}
```

## Local cache file

A table of *repos* and *commits* (of length 7) are stored in `{XDG_CACHE_HOME|HOME}.vis-outdated`.

File format:

| url | hash |
|-----|------|
| https://github.com/erf/vis-title.git | 98c037f |
| https://github.com/erf/vis-cursors.git |a9c615d |
