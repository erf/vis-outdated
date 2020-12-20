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

local fetch_hash = function(repo)
	local command = 'git ls-remote ' .. repo .. ' HEAD | cut -c1-7'
	local result = execute(command)
	return string.gsub(result, '[%s\n\r]', '')
end

local fetch_hashes = function(repos)
	local latest = {}
	for i, repo in ipairs(repos) do
		latest[repo] = fetch_hash(repo)
	end
	return latest
end

local per_repo_outdated = function()
	local local_hashes = read_hashes()
	local write_to_file = local_hashes == nil
	local latest_hashes = {}
	for i, repo in pairs(M.repos) do 
		local latest_hash = fetch_hash(repo)
		local local_hash = local_hashes and local_hashes[repo]
		if local_hash == nil then
			write_to_file = true
			local_hash = latest_hash
		end
		local short_repo = repo:match('^.*//(.*)')
		local str = '' .. short_repo .. ' ' .. local_hash .. ' -> ' .. latest_hash
		if local_hash == latest_hash then
			str = str .. ' LATEST'
		else
			str = str .. ' OUT-OF-DATE'
		end
		vis:message(str)
		vis:redraw()
		latest_hashes[repo] = latest_hash
	end
	-- write local hashes to file if not in sync with latest
	if write_to_file then
		write_hashes(latest_hashes)
	 end
end

local getFileName = function(url)
  return url:match("^.+/(.+)$")
end

vis:command_register('outdated', function()
	vis:message('fetching latest..')
	vis:redraw()
	per_repo_outdated()
	return true
end)

vis:command_register('outdated-up', function()
	vis:message('updating..')
	vis:redraw()
	local latest = fetch_hashes(M.repos)
	write_hashes(latest)
	vis:message('UP-TO-DATE')
	return true
end)

-- TODO move to vis-fetch?
-- git clone (shallow) repos to the vis-plugins folder
vis:command_register('outdated-install', function()
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
