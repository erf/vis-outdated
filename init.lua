local M = {}

local XDG_CACHE_HOME = os.getenv('XDG_CACHE_HOME')
if XDG_CACHE_HOME then 
	M.path = XDG_CACHE_HOME .. '/vis-outdated-hashes'
else
	M.path = os.getenv('HOME') .. '/.vis-outdated-hashes'
end

local hashes = {}

function file_exists(path)
	local f = io.open(path)
	if f == nil then return false
	else f:close() return true 
	end
end	

function read_outdated()
	hashes = {}
	local f = io.open(M.path)
	if f == nil then return end
	for line in f:lines() do
		for k, v in string.gmatch(line, '(.+)%s(%s+)') do
			hashes[k] = v
		end 
	end
	f:close()
end

function write_outdated()
	local f = io.open(M.path, 'w+')
	if f == nil then return end
	local a = {}
	for k in pairs(hashes) do table.insert(a, k) end
	table.sort(a)
	for i,k in ipairs(a) do 
		f:write(string.format('%s %s\n', k, hashes[k]))
	end
	f:close()
end

vis.events.subscribe(vis.events.INIT, function()
	-- TODO ? read local list of hashes
end)

function execute(command)
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end

function fetch_latest(repos)
	local latest = {}
	for i, repo in ipairs(repos) do
		local command = 'git ls-remote ' .. repo .. ' HEAD | cut -f1'
		local result = execute(command)
		local hash = string.gsub(result, '%s+', '')
		latest[repo] = hash
	end

	-- print repo + hash
	local str = ''
	for repo, hash in pairs(latest) do
		str = str .. repo .. " " .. hash .. '\n'
	end 
	vis:message(str)
end

vis:command_register('out-ls', function(argv, force, win, selection, range)

	-- TODO set in visrc.lua
	local repos = {
		'https://github.com/erf/vis-title',
		'https://github.com/erf/vis-cursors',
	}

	-- fetch a list of latest hash given a list of repos set via visrc.lua
	local latest = fetch_latest(repos)

	-- compare latest list of hashes with the outdated list, loaded from disk at 
	-- startup or updated using out-up command
	-- return a list with [repo, None | Old | Latest
	-- local diff = compare_to_local(latest, hashes)

	-- TODO print diff list

	return true
end)


return M
