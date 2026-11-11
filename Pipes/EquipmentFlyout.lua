local hook
local _E

local function GetLocation(loc)
	local data = EquipmentManager_GetLocationData(loc)
	if data.isBags then
		return data.bag, data.slot
	elseif data.isPlayer or data.isBank then
		return data.slot
	end
end

local function Pipe(self)
	if not CharacterFrame:IsShown() then return end
	local location = self.location
	local id, slot
	if (location and location < EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION) then
		id, slot = GetLocation(location)
	end

	return SyLevel:CallFilters("char-flyout", self, _E and id, slot)
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
