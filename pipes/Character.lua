local _E
local hook
local conflictingAddons = {
	"BetterCharacterPanel"
}

local slots = {
	"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
	"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
	"SecondaryHand", "Ranged", [19] = "Tabard",
}

local function update(self, key, slotFrame)
	if not (key or slotFrame) then return end
	SyLevel:CallFilters("char", slotFrame, _E and key)
end

local function pipe(self, slot)
	local slotFrame
	if slot and slots[slot] then
		slotFrame = _G["Character"..slots[slot].."Slot"]
		update(self, slot, slotFrame)
	else
		for key, slotName in pairs(slots) do
			slotFrame = _G["Character"..slotName.."Slot"]
			update(self, key, slotFrame)
		end
	end
end

local function PLAYER_EQUIPMENT_CHANGED(self, event, slot)
	pipe(self, slot)
end

local function doHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return pipe(...) end
		end
		CharacterFrame:HookScript("OnShow", pipe)
	end
end

local function enable(self)
	_E = true
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", PLAYER_EQUIPMENT_CHANGED)
	doHook()
end

local function disable(self)
	_E = nil
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED", PLAYER_EQUIPMENT_CHANGED)
end

SyLevel:RegisterPipe("char", enable, disable, update, "Character", nil, conflictingAddons)
