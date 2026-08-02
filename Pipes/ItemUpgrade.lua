local _, ns = ...
if not ns.Retail then return end

local hook
local _E

local function Pipe(self)
	local key, slot
	local itemLocation = self:GetItemLocation()
	if itemLocation then
		if itemLocation:IsBagAndSlot() then
			key, slot = itemLocation:GetBagAndSlot()
		elseif itemLocation:IsEquipmentSlot() then
			key = itemLocation:GetEquipmentSlot()
		end
	end
	return SyLevel:CallFilters("itemupgrade", self, _E and key, slot)
end

local function Update(self)
	if not ItemUpgradeFrame then return end
	local buttons = EquipmentFlyoutFrame.buttons
	for _, button in next, buttons do
		Pipe(button)
	end
end

local function DoHook()
	if (not hook) then
		hook = true
		hooksecurefunc("EquipmentFlyout_UpdateItems", Update)
	end
end

local function ADDON_LOADED(self)
	if (C_AddOns.IsAddOnLoaded("Blizzard_ItemUpgradeUI")) then
		DoHook()
		SyLevel:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Enable(self)
	_E = true

	if (C_AddOns.IsAddOnLoaded("Blizzard_ItemUpgradeUI")) then
		DoHook()
	else
		self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Disable(self)
	_E = nil
end

SyLevel:RegisterPipe("itemupgrade", Enable, Disable, Update, "Item Upgrade", nil)
