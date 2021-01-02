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

local is_full_url = function(url)
	return url:find('^.+://') ~= nil
end

local is_short_ssh_url = function(url)
	return url:find('^.+@.+:.+')
end

local get_full_url = function(url)
	if is_full_url(url) then
		return url
	elseif is_short_ssh_url(url) then
		return url
	else
		return 'https://github.com/' .. url
	end
end

local for_each_repo = function(func, args)
	local latest_hashes = {}
	for _, repo in ipairs(M.repos) do
		repo = get_full_url(repo)
		latest_hashes[repo] = func(repo, args)
	end
	return latest_hashes
end

local diff = function(repo, args)
	local local_hashes = args
	repo = get_full_url(repo)
	local latest_hash = fetch_hash(repo)
	local local_hash = local_hashes and local_hashes[repo]
	if local_hash == nil then
		local_hash = 'MISSING'
	end
	local str = '' .. repo .. ' ' .. local_hash .. ' -> ' .. latest_hash
	if local_hash == latest_hash then
		str = str .. ' LATEST'
	else
		str = str .. ' OUT-OF-DATE'
	end
	vis:message(str)
	vis:redraw()
	return latest_hash
end

local fetch = function(repo, args)
	local hash = fetch_hash(repo)
	vis:message('fetched ' .. repo .. ' -> ' .. hash)
	vis:redraw()
	return hash
end

vis:command_register('outdated', function()
	vis:message('fetching latest..')
	vis:redraw()
	for_each_repo(diff, read_hashes())
	vis:message('DONE')
	return true
end, 'compare local hashes to latest')

vis:command_register('outdated-update', function()
	vis:message('updating hashes..')
	vis:redraw()
	write_hashes(for_each_repo(fetch))
	vis:message('SAVED TO DISK')
	return true
end, 'write latest hashes to disk')

return M
