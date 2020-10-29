local M = {}

local XDG_CACHE_HOME = os.getenv('XDG_CACHE_HOME')
if XDG_CACHE_HOME then 
	M.path = XDG_CACHE_HOME .. '/vis-outdated'
else
	M.path = os.getenv('HOME') .. '/.vis-outdated'
end

-- [repo, hash] dict
--local hashes = {}

function file_exists(path)
	local f = io.open(path)
	if f == nil then return false
	else f:close() return true 
	end
end	

function read_hashes()
	local f = io.open(M.path)
	if f == nil then 
		return {}
	end
	local t= {}
	for line in f:lines() do
		for k, v in string.gmatch(line, '(.+)%s(%w+)') do
			t[k] = v
		end 
	end
	f:close()
	return t
end

function write_hashes(hashes)
	local f = io.open(M.path, 'w+')
	if f == nil then return end
	local t = {}
	for repo, hash in pairs(hashes) do 
		table.insert(t, repo .. ' ' .. hash)
	end
	local s = table.concat(t, '\n')
	f:write(s)
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

function fetch_hashes(repos)
	local latest = {}
	for i, repo in ipairs(repos) do
		local command = 'git ls-remote ' .. repo .. ' HEAD | cut -f1'
		local result = execute(command)
		local hash = string.gsub(result, '%s+', '')
		latest[repo] = hash
	end
	return latest
end

function get_hash_status(current, latest)
	if current == nil then
		return 'Not there'
	end

	if current == latest then
		return 'Latest'
	end 

	if current ~= latest then
		return 'Outdated'
	end
end

-- compare current with latest
function calc_diff(current, latest) 
	local diff = {}
	for repo, hash in pairs(latest) do
		local current_hash = current[repo]
		local status = get_hash_status(current_hash, hash)
		diff[repo] = { hash= hash, status= status }
	end
	return diff
end

function print_hashes(hashes)
	local t = {}
	for repo, hash in pairs(hashes) do
		table.insert(t, repo .. ' ' .. hash)
	end
	local s = table.concat(t, '\n')
	vis:message(s)
end


function print_diff(diff)
	local t = {}
	for repo, diff in pairs(diff) do
		table.insert(t, repo .. ' - ' .. diff.status) --.. diff.hash .. ')')
	end
	local s = table.concat(t, '\n')
	vis:message(s)
end

vis:command_register('out-ls', function(argv, force, win, selection, range)

	-- TODO move to visrc.lua
	local repos = {
		'https://github.com/erf/vis-title',
		'https://github.com/erf/vis-cursors',
	}

	local current = read_hashes()
	--print_hashes(current)

	local latest = fetch_hashes(repos)
	--print_hashes(latest)

	local diff = calc_diff(current, latest)
	print_diff(diff)


	--print_hashes(latest)
	--write_hashes(latest)
	-- startup or updated using out-up command
	-- return a list with [repo, None | Old | Latest
	-- local diff = compare_to_local(latest, hashes)
	-- TODO print diff list

	return true
end)


return M
