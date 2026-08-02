local _E
local slots = {
	"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
	"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
	"SecondaryHand", "Ranged", [19] = "Tabard",
}

local _MISSING = {}
local pollFrame = CreateFrame("Frame")
pollFrame:Hide()

local time = 3
pollFrame:SetScript("OnUpdate", function(self, elapsed)
	time = time + elapsed

	if (time >= 3) then
		local unit = InspectFrame.unit
		if (not unit) then
			self:Hide()
			wipe(_MISSING)
		end

		for i, slotName in next, _MISSING do
			local itemLink = GetInventoryItemLink(unit, i)
			if (itemLink) then
				SyLevel:CallFilters("inspect", _G["Inspect"..slotName.."Slot"], _E and itemLink)

				_MISSING[i] = nil
			end
		end

		if (not next(_MISSING)) then
			self:Hide()
		end
	end
end)

local function Update()
	if not InspectFrame then return end
	if (not InspectFrame:IsVisible()) then return end

	local unit = InspectFrame.unit
	for i, slotName in next, slots do
		local itemLink = GetInventoryItemLink(unit, i)
		local itemTexture = GetInventoryItemTexture(unit, i)

		if (itemTexture and not itemLink) then
			_MISSING[i] = slotName
			pollFrame:Show()
		end

		SyLevel:CallFilters("inspect", _G["Inspect"..slotName.."Slot"], _E and itemLink)
	end
end

local function UNIT_INVENTORY_CHANGED(self, event, unit)
	if (InspectFrame.unit == unit) then
		Update()
	end
end

local function ADDON_LOADED(self, event, addon)
	if (addon == "Blizzard_InspectUI") then
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Update)
		self:RegisterEvent("UNIT_INVENTORY_CHANGED", UNIT_INVENTORY_CHANGED)
		self:RegisterEvent("INSPECT_READY", Update)
		self:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Enable(self)
	_E = true

	if (C_AddOns.IsAddOnLoaded("Blizzard_InspectUI")) then
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Update)
		self:RegisterEvent("UNIT_INVENTORY_CHANGED", UNIT_INVENTORY_CHANGED)
		self:RegisterEvent("INSPECT_READY", Update)
	else
		self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Disable(self)
	_E = nil

	self:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	self:UnregisterEvent("PLAYER_TARGET_CHANGED", Update)
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED", UNIT_INVENTORY_CHANGED)
	self:UnregisterEvent("INSPECT_READY", Update)
end

SyLevel:RegisterPipe("inspect", Enable, Disable, Update, "Inspect Window", nil)
