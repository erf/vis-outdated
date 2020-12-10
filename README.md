# vis-outdated

Keep up-to-date with a list of git repos using [vis](https://github.com/martanne/vis).

> Also consider [vis-plug](https://github.com/erf/vis-plug)

## How

Given a set of git repos, we fetch the latest commit hashes using `git ls-remote` and store them in a local cache `~/.vis-outdated`. We can then compare the local hashes with the latest to see if they are up-to-date.

If you notice any repos are outdated, you need to update them yourself. `out-up` only update the local hash cache.

## Commands

**out-ls** - list current + latest repo hashes

**out-df** - check if current repos differ from latest

**out-up** - update local hash cache to latest

**out-in** - do a shallow git clone to **vis** `plugins` folder (no overwrite)

## Example

Example config:

```
require('plugins/vis-outdated').repos = {
	'https://github.com/erf/vis-title',
	'https://github.com/erf/vis-cursors',
	'https://github.com/erf/vis-highlight',
}
```

## Local cache file

A list of *repos* and *commit hashes* are stored in the file `.vis-outdated`, 
which is stored in either `XDG_CACHE_HOME` or in your `HOME` folder.

File format:

| url | hash |
|-----|------|
| https://github.com/erf/vis-title.git | 98c037f444b12f7cfaba25be954a582861f09990 |
| https://github.com/erf/vis-cursors.git |a9c615d16cbb8b0203cce9d988f72ae7dd327cf3 |
