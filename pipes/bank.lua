local _E

if (C_AddOns.IsAddOnLoaded("LiteBag")) then return end
if (C_AddOns.IsAddOnLoaded("Bagnon")) then return end
if (C_AddOns.IsAddOnLoaded("Inventorian")) then return end
if (C_AddOns.IsAddOnLoaded("Baganator")) then return end

local function update()
	if (not BankFrame:IsVisible()) then return end
	for i=1, NUM_BANKGENERIC_SLOTS or 28 do
		local slotFrame = _G["BankFrameItem"..i]
		SyLevel:CallFilters("bank", slotFrame, _E and -1, i)
	end
end

local function dispatch(self, event, id)
	if id == Enum.PlayerInteractionType.Banker then
		update()
	end
end

local function enable(self)
	_E = true

	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", dispatch)
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", update)
end

local function disable(self)
	_E = nil

	self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", dispatch)
	self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED", update)
end

SyLevel:RegisterPipe("bank", enable, disable, update, "Bank Window", nil)
