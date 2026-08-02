local _, ns = ...
if not ns.Retail then return end

local _E
local hook

local function Update(_, frame)
	if not frame then return end
	SyLevel:CallFilters("encounterjournal", frame.icon, _E and frame.link)
end

local function DoHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return Update(...) end
		end
		ScrollUtil.AddInitializedFrameCallback(EncounterJournal.encounter.info.LootContainer.ScrollBox, Update, nil, false)
	end
end

local function ADDON_LOADED(self, event, addon)
	if (addon == "Blizzard_EncounterJournal") then
		DoHook()
		SyLevel:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Enable(self)
	_E = true
	if C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
		DoHook()
	else
		SyLevel:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Disable(self)
	_E = nil
end

SyLevel:RegisterPipe("encounterjournal", Enable, Disable, Update, "Encounter Journal", nil)
