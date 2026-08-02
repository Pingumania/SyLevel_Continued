local _E

if (C_AddOns.IsAddOnLoaded("LiteBag")) then return end
if (C_AddOns.IsAddOnLoaded("Bagnon")) then return end
if (C_AddOns.IsAddOnLoaded("Inventorian")) then return end
if (C_AddOns.IsAddOnLoaded("Baganator")) then return end

local function Update()
	if (not BankFrame:IsVisible()) then return end
	for i=1, NUM_BANKGENERIC_SLOTS or 28 do
		local slotFrame = _G["BankFrameItem"..i]
		SyLevel:CallFilters("bank", slotFrame, _E and -1, i)
	end
end

local function Dispatch(self, event, id)
	if id == Enum.PlayerInteractionType.Banker then
		Update()
	end
end

local function Enable(self)
	_E = true

	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", Update)
end

local function Disable(self)
	_E = nil

	self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
	self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED", Update)
end

SyLevel:RegisterPipe("bank", Enable, Disable, Update, "Bank Window", nil)
