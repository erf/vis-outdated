# vis-outdated

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to check if a list of git repos (your favorite vis-plugins?) are up to date.

## How

Given a list of git repos, we fetch the latest commit hashes using `git ls-remote` and store them in a local cache `~/.vis-outdated`. Now we can compare the local hashes with the latest to see if they are out of date.

## Commands

**out-ls** - list current + latest repo hashes

**out-diff** - check if current repos are lagging behind

**out-up** - update local hashes to latest


## Example


Example configuration:

```
require('plugins/vis-outdated').repos = {
	'https://github.com/erf/vis-title',
	'https://github.com/erf/vis-cursors',
}
```

## Local cache date structure (.vis-outdated)

| url | hash |
|-----|------|
| https://github.com/erf/vis-title.git | 98c037f444b12f7cfaba25be954a582861f09990 |
| https://github.com/erf/vis-cursors.git |a9c615d16cbb8b0203cce9d988f72ae7dd327cf3 |
