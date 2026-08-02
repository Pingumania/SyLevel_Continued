local _, ns = ...
if ns.Classic then return end

local _E
local hook

local function UpdateContents()
	if (not VoidStorageFrame) then return end
	for slot = 1, VOID_WITHDRAW_MAX or 80 do
		local slotFrame = _G["VoidStorageStorageButton" .. slot]
		local page = _G["VoidStorageFrame"].page
		local itemID = GetVoidItemInfo(page, slot)
		local itemLink = itemID and select(2, C_Item.GetItemInfo(itemID))
		SyLevel:CallFilters("voidstore", slotFrame, _E and itemLink)
	end

	for slot = 1, VOID_WITHDRAW_MAX or 9 do
		local slotFrame = _G["VoidStorageWithdrawButton"..slot]
		local itemID = GetVoidTransferWithdrawalInfo(slot)
		local itemLink = itemID and select(2, C_Item.GetItemInfo(itemID))
		SyLevel:CallFilters("voidstore", slotFrame, _E and itemLink)
	end
end

local function UpdateDeposit(slot)
	local slotFrame = _G["VoidStorageDepositButton"..slot]
	local itemID = GetVoidTransferDepositInfo(slot)
	local itemLink = itemID and select(2, C_Item.GetItemInfo(itemID))
	SyLevel:CallFilters("voidstore", slotFrame, _E and itemLink)
end

local function Update(self)
	if (not VoidStorageFrame) then return end
	for slot = 1, VOID_DEPOSIT_MAX or 9 do
		UpdateDeposit(slot)
	end

	return UpdateContents()
end

local function Dispatch(self, event, id)
	if id == Enum.PlayerInteractionType.VoidStorageBanker then
		Update()
	end
end

local function DoHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return UpdateContents(...) end
		end
		hooksecurefunc("VoidStorage_SetPageNumber", UpdateContents)
	end
end

local function ADDON_LOADED(self)
	if (C_AddOns.IsAddOnLoaded("Blizzard_VoidStorageUI")) then
		DoHook()
		self:RegisterEvent("VOID_STORAGE_UPDATE", UpdateContents)
		self:RegisterEvent("INVENTORY_SEARCH_UPDATE", UpdateContents)
		self:RegisterEvent("VOID_DEPOSIT_WARNING", UpdateContents)
		self:RegisterEvent("VOID_STORAGE_CONTENTS_UPDATE", UpdateContents)
		self:RegisterEvent("VOID_STORAGE_DEPOSIT_UPDATE", UpdateDeposit)
		self:RegisterEvent("VOID_TRANSFER_DONE", Update)
		self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
		SyLevel:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Enable(self)
	_E = true

	if (C_AddOns.IsAddOnLoaded("Blizzard_VoidStorageUI")) then
		DoHook()
		self:RegisterEvent("VOID_STORAGE_UPDATE", UpdateContents)
		self:RegisterEvent("INVENTORY_SEARCH_UPDATE", UpdateContents)
		self:RegisterEvent("VOID_DEPOSIT_WARNING", UpdateContents)
		self:RegisterEvent("VOID_STORAGE_CONTENTS_UPDATE", UpdateContents)
		self:RegisterEvent("VOID_STORAGE_DEPOSIT_UPDATE", UpdateDeposit)
		self:RegisterEvent("VOID_TRANSFER_DONE", Update)
		self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
	else
		self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Disable(self)
	_E = nil
	self:UnregisterEvent("VOID_STORAGE_UPDATE", UpdateContents)
	self:UnregisterEvent("INVENTORY_SEARCH_UPDATE", UpdateContents)
	self:UnregisterEvent("VOID_DEPOSIT_WARNING", UpdateContents)
	self:UnregisterEvent("VOID_STORAGE_CONTENTS_UPDATE", UpdateContents)
	self:UnregisterEvent("VOID_STORAGE_DEPOSIT_UPDATE", UpdateDeposit)
	self:UnregisterEvent("VOID_TRANSFER_DONE", Update)
	self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
end

SyLevel:RegisterPipe("voidstore", Enable, Disable, Update, "Void Storage Window", nil)
