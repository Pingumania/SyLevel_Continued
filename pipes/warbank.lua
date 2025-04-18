local _E

if (C_AddOns.IsAddOnLoaded("LiteBag")) then return end
if (C_AddOns.IsAddOnLoaded("Bagnon")) then return end
if (C_AddOns.IsAddOnLoaded("Inventorian")) then return end
if (C_AddOns.IsAddOnLoaded("Baganator")) then return end

local function update()
	if (not BankFrame:IsVisible() or not BankFrame.activeTabIndex == 3) then return end
	for itemButton in AccountBankPanel:EnumerateValidItems() do
        local slotFrame = itemButton.IconBorder
        SyLevel:CallFilters("warbank", slotFrame, _E and itemButton.bankTabID, itemButton.containerSlotID)
	end
end

local function updateButton(self, event, ...)
    if event == "BAG_UPDATE" then
        local containerID = ...
		if AccountBankPanel.selectedTabID == containerID then
			update()
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

local function enable(self)
	_E = true

    EventUtil.ContinueOnAddOnLoaded("Blizzard_UIPanels_Game", function()
        hooksecurefunc(AccountBankPanel, "GenerateItemSlotsForSelectedTab", function()
            update()
        end)
    end)

    self:RegisterEvent("ITEM_LOCK_CHANGED", updateButton)
    self:RegisterEvent("BAG_UPDATE", updateButton)
end

local function disable(self)
	_E = nil
    self:UnregisterEvent("ITEM_LOCK_CHANGED")
    self:UnregisterEvent("BAG_UPDATE")
end

SyLevel:RegisterPipe("warbank", enable, disable, update, "Warbank Window", nil)