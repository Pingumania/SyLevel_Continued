local _E
local hook

local function update(_, frame)
	if not frame then return end
	SyLevel:CallFilters("adventureguide", frame.icon, _E and frame.link)
end

local function doHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return update(...) end
		end
		ScrollUtil.AddInitializedFrameCallback(EncounterJournal.encounter.info.LootContainer.ScrollBox, update, nil, false)
	end
end

local function ADDON_LOADED(self, event, addon)
	if (addon == "Blizzard_EncounterJournal") then
		doHook()
		SyLevel:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function enable(self)
	_E = true
	if C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
		doHook()
	else
		SyLevel:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function disable(self)
	_E = nil
end

SyLevel:RegisterPipe("adventureguide", enable, disable, update, "AdventureGuide", nil)