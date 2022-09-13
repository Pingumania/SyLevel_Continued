local hook
local _E

local function getIL(self)
	local itemLocation = self:GetItemLocation()
	if itemLocation:IsBagAndSlot() then
		local bag, slot = itemLocation:GetBagAndSlot()
		return GetContainerItemLink(bag, slot)
	elseif itemLocation:IsEquipmentSlot() then
		local slot = itemLocation:GetEquipmentSlot()
		return GetInventoryItemLink("player", slot)
	end
end

local function pipe(self)
	local itemLink = getIL(self)

	return SyLevel:CallFilters("item-upgrade", self, _E and itemLink)
end

local function update(self)
	if not ItemUpgradeFrame:IsShown() then return end
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
	if (IsAddOnLoaded("Blizzard_ItemUpgradeUI")) then
		doHook()
		SyLevel:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function enable(self)
	_E = true

	if (IsAddOnLoaded("Blizzard_ItemUpgradeUI")) then
		doHook()
	else
		self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function disable(self)
	_E = nil
end

SyLevel:RegisterPipe("item-upgrade", enable, disable, update, "Item Upgrade", nil)
