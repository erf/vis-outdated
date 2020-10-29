# vis-outdated

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to check if a list of git repos are up to date.

> Instead of using a complex [plugin manager](https://github.com/erf/vis-plug) to keep your `vis-plugins` up to date, this might work as a simpler solution. Or if you just want to keep up-to-date with som arbitrary git repo.

## How

Given a list of git repos, we fetch the latest commit hashes using `git ls-remote` and store them in a local cache `~/.vis-outdated`. Now we can compare the local hashes with the latest to see if they are up-to-date.

Note: Once you notice any repos are outdated, you need to update them yourself, `out-up` only updates the local hashes.

## Commands

**out-ls** - list current + latest repo hashes

**out-df** - check if current repos are lagging behind

**out-up** - update local hashes to latest

**out-in** - secret command for installing vis plugins


## Example


Example configuration:

```
require('plugins/vis-outdated').repos = {
	'https://github.com/erf/vis-title',
	'https://github.com/erf/vis-cursors',
}
```

## Local cache date structure

`.vis-outdated`, and it is stored either in `XDG_CACHE_HOME` or in your `HOME` folder.

| url | hash |
|-----|------|
| https://github.com/erf/vis-title.git | 98c037f444b12f7cfaba25be954a582861f09990 |
| https://github.com/erf/vis-cursors.git |a9c615d16cbb8b0203cce9d988f72ae7dd327cf3 |
