local _, ns = ...
local SyLevel = ns.SyLevel

local pipesTable = {}
local numPipes = 0

local argcheck = SyLevel.argcheck

function SyLevel:ShouldSkipPipe(conflictingAddons)
    for _, addon in ipairs(conflictingAddons) do
        if C_AddOns.IsAddOnLoaded(addon) then
            return true
        end
    end
    return false
end

function SyLevel:RegisterPipe(pipe, enable, disable, update, name, desc, conflictingAddons)
	argcheck(pipe, 2, "string")
	argcheck(enable, 3, "function")
	argcheck(disable, 4, "function", "nil")
	argcheck(update, 5, "function")
	argcheck(name, 6, "string", "nil")
	argcheck(desc, 7, "string", "nil")
	argcheck(conflictingAddons, 8, "table", "nil")

	if conflictingAddons and SyLevel:ShouldSkipPipe(conflictingAddons) then
		print(pipe)
		return nil
	end

	-- Silently fail.
	if (pipesTable[pipe]) then
		return nil
	else
		numPipes = numPipes + 1

		pipesTable[pipe] = {
			enable = enable;
			disable = disable;
			name = name;
			update = update;
			desc = desc;
			conflictingAddons = conflictingAddons;
		}
	end
	return true
end

do
	local function iter(_, n)
		local m, t = next(pipesTable, n)
		if (t) then
			return m, t.isActive, t.name, t.desc
		end
	end

	function SyLevel.IteratePipes()
		return iter, nil, nil
	end
end

function SyLevel:EnablePipe(pipe)
	argcheck(pipe, 2, "string")

	local ref = pipesTable[pipe]

	if (ref and not ref.isActive) then
		ref.enable(self)
		ref.isActive = true

		SyLevelDB.EnabledPipes[pipe] = true
		return true
	end
end

function SyLevel:DisablePipe(pipe)
	argcheck(pipe, 2, "string")

	local ref = pipesTable[pipe]
	if (ref and ref.isActive) then
		if (ref.disable) then ref.disable(self) end
		ref.isActive = false

		SyLevelDB.EnabledPipes[pipe] = false

		return true
	end
end

function SyLevel:IsPipeEnabled(pipe)
	argcheck(pipe, 2, "string")

	return pipesTable[pipe].isActive
end

function SyLevel:UpdatePipe(pipe)
	argcheck(pipe, 2, "string")

	local ref = pipesTable[pipe]
	if (ref) then
		ref.update(self)

		return true
	end
end

function SyLevel:GetNumPipes()
	return numPipes
end

ns.pipesTable = pipesTable