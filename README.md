# vis-outdated

A [vis-plugin](https://github.com/martanne/vis/wiki/Plugins/) to check if a list of git repos (your favorite vis-plugins?) are up to date.

## How

Given a list of git `repos` in your `visrc.lua` file, we fetch the latest commit hash per repo using `git ls-remote` and store them in a local cache `~/.vis-outdated` (on `out-up`).

On `out-diff`, if the local hash does not match with the latest, we show it as outdated.

`out-ls` fetches the latest commit hashes and prints them, together with the local cache.

## Commands

**out-ls** - list current + latest repo hashes

**out-diff** - check if current repos are lagging behind

**out-up** - update local hashes to latest


## Local cache date structure (.vis-outdated)

| url | hash |
|-----|------|
| https://github.com/martanne/vis.git | 3fe8d2ecb9fafc67b2731419a47a1b467f381dae |
| https://github.com/erf/vis-cursors.git |f36f51f60070298bb19fb92f58acc06e8dc6a0c6 |

## Example


Example configuration:

```
require('plugins/vis-outdated').repos = {
	'https://github.com/erf/vis-title',
	'https://github.com/erf/vis-cursors',
}
```

