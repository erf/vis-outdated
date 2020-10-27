local M = {}

local XDG_CACHE_HOME = os.getenv('XDG_CACHE_HOME')
if XDG_CACHE_HOME then 
	M.path =  XDG_CACHE_HOME .. '/vis-outdated'
else
	M.path = os.getenv('HOME') .. '/.vis-outdated'
end

local outdated = {}

function file_exists(path)
	local f = io.open(path)
	if f == nil then return false
	else f:close() return true 
	end
end	

function read_outdated()
	outdated = {}
	local f = io.open(M.path)
	if f == nil then return end
	for line in f:lines() do
		for k, v in string.gmatch(line, '(.+)%s(%s+)') do
			outdated[k] = v
		end 
	end
	f:close()
end

function write_outdated()
	local f = io.open(M.path, 'w+')
	if f == nil then return end
	local a = {}
	for k in pairs(outdated) do table.insert(a, k) end
	table.sort(a)
	for i,k in ipairs(a) do 
		f:write(string.format('%s %s\n', k, outdated[k]))
	end
	f:close()
end

vis.events.subscribe(vis.events.INIT, read_outdated)

vis:command_register('out-ls', function(argv, force, win, selection, range)

	-- TODO set in visrc.lua
	local repo_list {
		'https://github.com/erf/vis-title',
		'https://github.com/erf/vis-cursors',
	}

	-- fetch a list of latest hash given a list of repos set via visrc.lua
	local latest = fetch_latest(repo_list)

	-- compare latest list of hashes with the outdated list, loaded from disk at 
	-- startup or updated using out-up command
	-- return a list with [repo, None | Old | Latest
	local diff = compare_latest_to_current_values(latest, outdated)

	-- TODO print diff list

	return true
end)


return M
