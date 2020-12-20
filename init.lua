local M = {}
local HOME = os.getenv('HOME')
local XDG_CACHE_HOME = os.getenv('XDG_CACHE_HOME')
local BASE = XDG_CACHE_HOME or HOME

M.path = BASE .. '/.vis-outdated'

-- configure in visrc
M.repos = {}

local concat = function(iterable, func)
	local arr = {}
	for key, val in pairs(iterable) do
		table.insert(arr, func(key, val))
	end
	return table.concat(arr, '\n')
end

local read_hashes = function()
	local f = io.open(M.path)
	if f == nil then
		return nil
	end
	local result= {}
	for line in f:lines() do
		for k, v in string.gmatch(line, '(.+)%s(%w+)') do
			result[k] = v
		end
	end
	f:close()
	return result
end

local write_hashes = function(hashes)
	local f = io.open(M.path, 'w+')
	if f == nil then
		return
	end
	local str = concat(hashes, function(repo, hash)
		return repo .. ' ' .. hash
	end)
	f:write(str)
	f:close()
end

local execute = function(command)
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end

local fetch_hash_for_repo = function(repo)
	local command = 'git ls-remote ' .. repo .. ' HEAD | cut -c1-7'
	local result = execute(command)
	return string.gsub(result, '[%s\n\r]', '')
end

local fetch_hashes = function(repos)
	local latest = {}
	for i, repo in ipairs(repos) do
		latest[repo] = fetch_hash_for_repo(repo)
	end
	return latest
end

local combine_hashes = function(local_hashes, latest_hashes)
	local diff = {}
	for repo, latest_hash in pairs(latest_hashes) do
		local local_hash = local_hashes[repo]
		local str = '' .. repo .. ' ' .. local_hash .. ' -> ' .. latest_hash
		if local_hash == latest_hash then
			str = str .. ' LATEST'
		else
			str = str .. ' OUT-OF-DATE'
		end
		diff[repo] = str
	end
	return diff
end

local getFileName = function(url)
  return url:match("^.+/(.+)$")
end

vis:command_register('out-diff', function()
	vis:message('fetching latest..')
	vis:redraw()
	local local_hashes = read_hashes()
	local latest_hashes = fetch_hashes(M.repos)
	if local_hashes == nil then
		local_hashes = latest_hashes
		write_hashes(latest_hashes)
	end
	local combined = combine_hashes(local_hashes, latest_hashes)
	local str = concat(combined, function(_, val) return val end)
	vis:message(str)
	return true
end)

vis:command_register('out-update', function()
	vis:info('updating..')
	local latest = fetch_hashes(M.repos)
	write_hashes(latest)
	vis:info('fetched and wrote hashes')
	return true
end)

-- TODO move to vis-fetch?
-- git clone (shallow) repos to the vis-plugins folder
vis:command_register('out-install', function()
	local visrc, err = package.searchpath('visrc', package.path)
	assert(not err)
	local vis_path = visrc:match('(.*/)')
	assert(vis_path)
	local path = vis_path ..'plugins'
	vis:message('installing to ' .. path)
	for i, url in ipairs(M.repos) do
		local name = getFileName(url)
		execute('git -C ' .. path .. ' clone --depth 1 --branch=master ' .. url .. ' --quiet 2> /dev/null')
		vis:message('git cloned (shallow) ' .. url .. ' to ' .. name)
	end
	return true
end)

return M
