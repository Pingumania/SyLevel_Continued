local _, ns = ...
local SyLevel = ns.SyLevel

local argcheck = SyLevel.argcheck
local pipesTable = ns.pipesTable

local filtersTable = {}
local activeFilters = {}
local numFilters = 0

function SyLevel:RegisterFilter(name, type, filter, desc)
	argcheck(name, 2, "string")
	argcheck(type, 3, "string")
	argcheck(filter, 4, "function")
	argcheck(desc, 5, "string", "nil")

	if (filtersTable[name]) then return nil, "Filter function is already registered." end
	filtersTable[name] = {type, filter, name, desc}

	numFilters = numFilters + 1

	return true
end

do
	local function Iter(_, n)
		local m, t = next(filtersTable, n)
		if (t) then
			return m, t[1], t[4]
		end
	end

	function SyLevel.IterateFilters()
		return Iter, nil, nil
	end
end

-- TODO: Validate that the display we try to use actually exists.
function SyLevel:RegisterFilterOnPipe(pipe, filter)
	argcheck(pipe, 2, "string")
	argcheck(filter, 3, "string")

	if (not pipesTable[pipe]) then return nil, "Pipe does not exist." end
	if (not filtersTable[filter]) then return nil, "Filter does not exist." end

	local filterTable = filtersTable[filter]
	local display = filterTable[1]

	-- XXX: Clean up this logic.
	if (not activeFilters[pipe]) then
		activeFilters[pipe] = {}
		activeFilters[pipe][display] = {}
		table.insert(activeFilters[pipe][display], filterTable)
	elseif (not activeFilters[pipe][display]) then
		activeFilters[pipe][display] = {}
		table.insert(activeFilters[pipe][display], filterTable)
	else
		local ref = activeFilters[pipe][display]

		for _, func in next, ref do
			if (func == filterTable) then
				return nil, "Filter function is already registered."
			end
		end
		table.insert(ref, filterTable)
	end

	if (not SyLevelDB.EnabledFilters[filter]) then
		SyLevelDB.EnabledFilters[filter] = {}
	end
	SyLevelDB.EnabledFilters[filter][pipe] = true

	return true
end

function SyLevel:UnregisterFilterOnPipe(pipe, filter)
	argcheck(pipe, 2, "string")
	argcheck(filter, 3, "string")

	if (not pipesTable[pipe]) then return nil, "Pipe does not exist." end
	if (not filtersTable[filter]) then return nil, "Filter does not exist." end

	local filterTable = filtersTable[filter]
	local ref = activeFilters[pipe] and activeFilters[pipe][filterTable[1]]
	if (ref) then
		for k = #ref, 1, -1 do
			if (ref[k] == filterTable) then
				table.remove(ref, k)
			end
		end

		if (SyLevelDB.EnabledFilters[filter]) then
			SyLevelDB.EnabledFilters[filter][pipe] = nil
		end

		return true
	end
end

function SyLevel:GetNumFilters()
	return numFilters
end

ns.filtersTable = filtersTable
ns.activeFilters = activeFilters
