local _E
local hook

local function updateContents()
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

local function updateDeposit(slot)
	local slotFrame = _G["VoidStorageDepositButton"..slot]
	local itemID = GetVoidTransferDepositInfo(slot)
	local itemLink = itemID and select(2, C_Item.GetItemInfo(itemID))
	SyLevel:CallFilters("voidstore", slotFrame, _E and itemLink)
end

local function update(self)
	if (not VoidStorageFrame) then return end
	for slot = 1, VOID_DEPOSIT_MAX or 9 do
		updateDeposit(slot)
	end

	return updateContents()
end

local function dispatch(self, event, id)
	if id == Enum.PlayerInteractionType.VoidStorageBanker then
		update()
	end
end

local function doHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return updateContents(...) end
		end
		hooksecurefunc("VoidStorage_SetPageNumber", updateContents)
	end
end

local function ADDON_LOADED(self)
	if (C_AddOns.IsAddOnLoaded("Blizzard_VoidStorageUI")) then
		doHook()
		self:RegisterEvent("VOID_STORAGE_UPDATE", updateContents)
		self:RegisterEvent("INVENTORY_SEARCH_UPDATE", updateContents)
		self:RegisterEvent("VOID_DEPOSIT_WARNING", updateContents)
		self:RegisterEvent("VOID_STORAGE_CONTENTS_UPDATE", updateContents)
		self:RegisterEvent("VOID_STORAGE_DEPOSIT_UPDATE", updateDeposit)
		self:RegisterEvent("VOID_TRANSFER_DONE", update)
		self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", dispatch)
		SyLevel:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function enable(self)
	_E = true

	if (C_AddOns.IsAddOnLoaded("Blizzard_VoidStorageUI")) then
		doHook()
		self:RegisterEvent("VOID_STORAGE_UPDATE", updateContents)
		self:RegisterEvent("INVENTORY_SEARCH_UPDATE", updateContents)
		self:RegisterEvent("VOID_DEPOSIT_WARNING", updateContents)
		self:RegisterEvent("VOID_STORAGE_CONTENTS_UPDATE", updateContents)
		self:RegisterEvent("VOID_STORAGE_DEPOSIT_UPDATE", updateDeposit)
		self:RegisterEvent("VOID_TRANSFER_DONE", update)
		self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", dispatch)
	else
		self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function disable(self)
	_E = nil
	self:UnregisterEvent("VOID_STORAGE_UPDATE", updateContents)
	self:UnregisterEvent("INVENTORY_SEARCH_UPDATE", updateContents)
	self:UnregisterEvent("VOID_DEPOSIT_WARNING", updateContents)
	self:UnregisterEvent("VOID_STORAGE_CONTENTS_UPDATE", updateContents)
	self:UnregisterEvent("VOID_STORAGE_DEPOSIT_UPDATE", updateDeposit)
	self:UnregisterEvent("VOID_TRANSFER_DONE", update)
	self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", dispatch)
end

SyLevel:RegisterPipe("voidstore", enable, disable, update, "Void Storage Window", nil)