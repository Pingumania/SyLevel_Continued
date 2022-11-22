local _E
local hook

local function update(outputIcon, _, _, _, itemIDOrLink)
	SyLevel:CallFilters("tradeskill", outputIcon, _E and itemIDOrLink)
end

local function doHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return update(...) end
		end
		hooksecurefunc(Professions, "SetupOutputIconCommon", hook)
	end
end

local function ADDON_LOADED(self, event, addon)
	if (addon == "Blizzard_Professions") then
		doHook()
		self:UnregisterEvent(event, ADDON_LOADED)
	end
end

local function enable(self)
	_E = true

	if (IsAddOnLoaded("Blizzard_Professions")) then
		doHook()
	else
		self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function disable(self)
	_E = nil
	self:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
end

SyLevel:RegisterPipe("tradeskill", enable, disable, update, "Profession Window", nil)