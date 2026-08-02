local _, ns = ...
if not ns.Retail then return end

if (C_AddOns.IsAddOnLoaded("Baganator")) then return end

local _E

local function Update()
	if (not AccountBankPanel or not BankFrame:IsVisible() or not BankFrame.activeTabIndex == 3) then return end
	for itemButton in AccountBankPanel:EnumerateValidItems() do
		local slotFrame = itemButton.IconBorder
		SyLevel:CallFilters("warbank", slotFrame, _E and itemButton.bankTabID, itemButton.containerSlotID)
	end
end

local function UpdateButton(self, event, ...)
	if not AccountBankPanel then return end

	if event == "BAG_UPDATE" then
		local containerID = ...
		if AccountBankPanel.selectedTabID == containerID then
			Update()
		end
	elseif event == "ITEM_LOCK_CHANGED" then
		local bankTabID, containerSlotID = ...
		local itemInSelectedTab = bankTabID == AccountBankPanel:GetSelectedTabID()
		if not itemInSelectedTab then
			return
		end

		local itemButton = AccountBankPanel:FindItemButtonByContainerSlotID(containerSlotID)
		if itemButton then
			SyLevel:CallFilters("warbank", itemButton.IconBorder, _E and itemButton.bankTabID, itemButton.containerSlotID)
		end
	end
end

local function Enable(self)
	_E = true

	EventUtil.ContinueOnAddOnLoaded("Blizzard_UIPanels_Game", function()
		if AccountBankPanel then
			hooksecurefunc(AccountBankPanel, "GenerateItemSlotsForSelectedTab", function()
				Update()
			end)
		end
	end)

	self:RegisterEvent("ITEM_LOCK_CHANGED", UpdateButton)
	self:RegisterEvent("BAG_UPDATE", UpdateButton)
end

local function Disable(self)
	_E = nil
	self:UnregisterEvent("ITEM_LOCK_CHANGED")
	self:UnregisterEvent("BAG_UPDATE")
end

SyLevel:RegisterPipe("warbank", Enable, Disable, Update, "Warbank Window", nil)
