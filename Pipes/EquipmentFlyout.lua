local hook
local _E

local function GetIL(loc)
	local Player, bank, bags, _, slot, bag = EquipmentManager_UnpackLocation(loc)
	if (not Player and not bank and not bags) then return end
	if (not bags) then
		return GetInventoryItemLink("player", slot)
	else
		return C_Container.GetContainerItemLink(bag, slot)
	end
end

local function Pipe(self)
	if not CharacterFrame:IsShown() then return end
	local location = self.location
	local itemLink
	if (location and location < EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION) then
		itemLink = GetIL(location)
	end

	return SyLevel:CallFilters("char-flyout", self, _E and itemLink)
end

local function Update(self)
	if not CharacterFrame:IsShown() then return end
	local buttons = EquipmentFlyoutFrame.buttons
	for _, button in next, buttons do
		Pipe(button)
	end
end

local function Enable(self)
	_E = true

	if (not hook) then
		hooksecurefunc("EquipmentFlyout_DisplayButton", Pipe)
		hook = true
	end
end

local function Disable(self)
	_E = nil
end

SyLevel:RegisterPipe("char-flyout", Enable, Disable, Update, "Character Equipment Flyout", nil)
