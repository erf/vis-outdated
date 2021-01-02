local M = {}

local get_default_cache_path = function()
	local HOME = os.getenv('HOME')
	local XDG_CACHE_HOME = os.getenv('XDG_CACHE_HOME')
	local BASE = XDG_CACHE_HOME or HOME
	return BASE .. '/.vis-outdated.csv'
end

M.path = get_default_cache_path()

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
		for k, v in string.gmatch(line, '(.+)[,%s](%w+)') do
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
	local str = concat(hashes, function(url, hash)
		return url .. ',' .. hash
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
end, 'compare local hashes to latest')

vis:command_register('outdated-update', function()
	vis:message('updating hashes..')
	vis:redraw()
	write_hashes(fetch_hashes(M.repos))
	vis:message('UP-TO-DATE')
	return true
end, 'update local hashes from latest')

return M
