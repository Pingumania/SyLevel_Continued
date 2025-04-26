local _, ns = ...
if not ns.Retail then return end

local hook
local _E

local function pipe(self)
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

local function update(self)
	if not ItemUpgradeFrame then return end
	local buttons = EquipmentFlyoutFrame.buttons
	for _, button in next, buttons do
		pipe(button)
	end
end

local function doHook()
	if (not hook) then
		hook = true
		hooksecurefunc("EquipmentFlyout_UpdateItems", update)
	end
end

local function ADDON_LOADED(self)
	if (C_AddOns.IsAddOnLoaded("Blizzard_ItemUpgradeUI")) then
		doHook()
		SyLevel:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function enable(self)
	_E = true

	if (C_AddOns.IsAddOnLoaded("Blizzard_ItemUpgradeUI")) then
		doHook()
	else
		self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function disable(self)
	_E = nil
end

SyLevel:RegisterPipe("itemupgrade", enable, disable, update, "Item Upgrade", nil)
